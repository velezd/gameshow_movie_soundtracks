extends Control

var MUTE = true
var MUTE_ICON = [preload("res://textures/icons/sound_off.png"),
                 preload("res://textures/icons/sound_on.png")]

var BACKGROUNDS = [preload("res://textures/game_background_off.png"),
                   preload("res://textures/game_background_on.png")]

var GUESSING_ENABLED = true

# Called when the node enters the scene tree for the first time.
func _ready():
    AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
    var player_scene = preload("res://player.tscn")
    $btn_iknow.connect('pressed', _on_iknow_pressed)
    $btn_mute.connect('pressed', _on_mute_pressed)
    
    var offset = 0
    # If there is more than 10 players start drawing them higher
    var offset_top = 500 if len(Game.PLAYERS_LIST) < 11 else 380
    var player_count = 0
    for id in Game.PLAYERS_LIST:
        # After 10th player reset left offest and move top offset down
        if player_count == 10:
            offset = 0
            offset_top = 500

        var player = Game.PLAYERS_LIST[id]
        var player_node = player_scene.instantiate()
        player_node.set_name('plr_' + str(id))
        player_node.get_node('img_avatar').texture = Game.AVATARS[player['avatar']]
        player_node.get_node('label_name').text = player['name']
        player_node.get_node('label_score').text = str(player['score'])
        player_node.offset_left = offset
        player_node.offset_top = offset_top
        offset += 105
        self.add_child(player_node)
        player_count += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed('ui_guess') and self.GUESSING_ENABLED:
        _on_iknow_pressed()

func _on_iknow_pressed():
    Game.i_know()
    
func _on_mute_pressed():
    if self.MUTE:
        AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
        self.MUTE = false
        $btn_mute.icon = self.MUTE_ICON[1]
    else:
        AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
        self.MUTE = true
        $btn_mute.icon = self.MUTE_ICON[0]

func update_scores():
    for id in Game.PLAYERS_LIST:
        get_node('plr_' + str(id) + '/label_score').text = str(Game.PLAYERS_LIST[id]['score'])

func show_movie():
    $background.texture = self.BACKGROUNDS[1]
    $poster.visible = true

func hide_movie():
    $background.texture = self.BACKGROUNDS[0]
    $poster.visible = false

func load_movie(id):
    var movie = Game.MOVIES[id]
    $AudioStreamPlayer.stream = movie['music']
    $poster.texture = movie['image']

func stop_guessing():
    self.GUESSING_ENABLED = false
    $/root/main/client/btn_iknow.visible = false
    
func resume_guessing():
    self.GUESSING_ENABLED = true
    $/root/main/client/btn_iknow.visible = true

#@rpc
#func play_music():
#    if $AudioStreamPlayer.stream_paused:
#        $AudioStreamPlayer.stream_paused = false
#    else:
#        $AudioStreamPlayer.play()

#@rpc
#func pause_music():
#    $AudioStreamPlayer.stream_paused = true
