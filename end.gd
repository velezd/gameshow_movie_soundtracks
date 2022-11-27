extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
    # Get winners
    var winners = []
    var winning_score = 0
    for player in Game.PLAYERS_LIST:
        if Game.PLAYERS_LIST[player]['score'] == winning_score:
            winners.append(player)
        if Game.PLAYERS_LIST[player]['score'] > winning_score:
            winning_score = Game.PLAYERS_LIST[player]['score']
            winners = [player]

    # Show winners
    var offset = 520 - len(winners) * 48
    var player_scene = preload("res://player.tscn")
    for id in winners:
        var player = Game.PLAYERS_LIST[id]
        var player_node = player_scene.instantiate()
        player_node.set_name('plr_' + str(id))
        player_node.get_node('img_avatar').texture = Game.AVATARS[player['avatar']]
        player_node.get_node('label_name').text = player['name']
        player_node.get_node('label_score').text = str(player['score'])
        player_node.offset_left = offset
        player_node.offset_top = 200
        offset += 100
        self.add_child(player_node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
