extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
    $control_connect/btn_connect.connect('pressed', _on_connect_pressed)
    $control_connect/btn_server.connect('pressed', _on_server_pressed)
    $control_server/btn_start_game.connect('pressed', _on_start_game_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

# Server side
func _on_server_pressed():
    $control_connect.visible = false
    
    var peer = ENetMultiplayerPeer.new()
    multiplayer.peer_connected.connect(self.connected_player)
    multiplayer.peer_disconnected.connect(self.disconnected_player)
    peer.create_server(Game.SERVER_PORT)
    multiplayer.set_multiplayer_peer(peer)

    # get local ips
    var ips = ''
    for address in IP.get_local_addresses():
        if (address.split('.').size() == 4) and not address.begins_with('127'):
            ips += address + '\n'

    # show server ui
    $control_server.visible = true
    $control_lobby.visible = true
    $control_server/label_server_ip_addr.text = ips

func disconnected_player(id: int):
    $/root/main/statusbar.text = 'Player disconnected ' + str(id)
    # remove player from lobby list on server
    $control_lobby/list_players.remove_item(Game.PLAYERS_LIST[id]['lobby_idx'])
    # remove player from players list
    Game.PLAYERS_LIST.erase(id)
    # sync players to clients
    rpc('sync_players', Game.PLAYERS_LIST)

func connected_player(id: int):
    $/root/main/statusbar.text = 'Player connected ' + str(id)

func _on_start_game_pressed():
    $/root/main/statusbar.text = ''
    rpc('change_scene', 'res://client.tscn')
    self.change_scene('res://host.tscn')

@rpc(any_peer)
func register_player(player_info):
    """ Register player on server """
    print('adding player: ' + player_info[0])
    var id = multiplayer.get_remote_sender_id()
    
    # Refuse connection if player with the same name is already connected
    for player in Game.PLAYERS_LIST:
        if Game.PLAYERS_LIST[id]['name'] == player_info[0]:
            $/root/main/statusbar.text = 'Player kicked ' + str(id)
            rpc_id(id, 'kicked', 'name already used')
            return false
    
    # Show player in lobby list on server
    var idx = $control_lobby/list_players.add_item(player_info[0])
    # add player to players list
    Game.PLAYERS_LIST[id] = {'name': player_info[0], 'lobby_idx': idx, 'avatar': player_info[1], 'score': 0}

    rpc('sync_players', Game.PLAYERS_LIST)


# Client side
func _on_connect_pressed():
    var player_name = $control_connect/line_edit_name
    var ip = $control_connect/line_edit_ip
    
    if player_name.text == '':
        player_name.placeholder_text = 'required'
        return
    if ip.text == '':
        ip.placeholder_text = 'required'
        return

    $control_connect.visible = false
    $/root/main/statusbar.text = 'Connecting...'

    # connect to server
    var peer = ENetMultiplayerPeer.new()
    print(peer.create_client(ip.text, Game.SERVER_PORT))
    multiplayer.connected_to_server.connect(self.connected_to_server)
    multiplayer.connection_failed.connect(self.connection_failed)
    multiplayer.set_multiplayer_peer(peer)

func connection_failed():
    $control_connect.visible = true
    $control_lobby.visible = false
    $/root/main/statusbar.text = 'Connection failed'

func connected_to_server():
    """ Once connected to server register player name """
    $/root/main/statusbar.text = ''
    var player_name = $control_connect/line_edit_name.text
    var avatar = $control_connect/control_avatar.option
    rpc_id(1, 'register_player', [player_name, avatar])
    $control_lobby.visible = true

@rpc
func kicked(reason):
    $/root/main/statusbar.text = 'Disconnected: ' + reason
    get_tree().network_peer = null
    multiplayer.set_multiplayer_peer(null)

@rpc
func sync_players(players):
    """ Sync list of players in clients """
    $control_lobby/list_players.clear()
    for player in players.values():
        $control_lobby/list_players.add_item(player['name'])
    Game.PLAYERS_LIST = players

@rpc
func change_scene(scene):
    # Add the next level
    var next_level = load(scene).instantiate()
    $/root/main.add_child(next_level)

    # Remove the current level
    var menu = $/root/main.get_node('menu')
    $/root/main.remove_child(menu)
    menu.call_deferred('free')
