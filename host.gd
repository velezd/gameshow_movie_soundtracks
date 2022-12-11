extends Control

var GUESSING = false
var GUESSING_PLAYER = -1

# Called when the node enters the scene tree for the first time.
func _ready():
    $btn_play.connect('pressed', _on_play_pressed)
    $btn_pause.connect('pressed', _on_pause_pressed)
    $btn_next.connect('pressed', _on_next_pressed)
    $btn_correct.connect('pressed', _on_correct_pressed)
    $btn_wrong.connect('pressed', _on_wrong_pressed)
    $btn_show.connect('pressed', _on_show_pressed)
    load_movie(Game.CURRENT_MOVIE)
    update_player_list(104)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    $ProgressBar.value = $AudioStreamPlayer.get_playback_position()

func _on_play_pressed():
    Game.client_play_music()
    if $AudioStreamPlayer.stream_paused:
        $AudioStreamPlayer.stream_paused = false
    else:
        $AudioStreamPlayer.play()
    $btn_play.disabled = true
    $btn_pause.disabled = false

func _on_pause_pressed():
    Game.client_pause_music()
    $AudioStreamPlayer.stream_paused = true
    $btn_play.disabled = false
    $btn_pause.disabled = true

func _on_next_pressed():
    Game.CURRENT_MOVIE += 1
    if Game.CURRENT_MOVIE < len(Game.MOVIES):
        load_movie(Game.CURRENT_MOVIE)
        Game.resume_guessing()
    else:
        Game.show_winners()

func _on_correct_pressed():
    answer_is(true)

func _on_wrong_pressed():
    answer_is(false)

func _on_show_pressed():
    Game.client_show_movie()

func print_state():
    print(Game.MOVIES[Game.CURRENT_MOVIE]['name'])
    for player in Game.PLAYERS_LIST.values():
        print(player['name'] + ' - ' + str(player['score']))

func answer_is(correct):
    if correct:
        Game.client_show_movie()
        Game.PLAYERS_LIST[self.GUESSING_PLAYER]['score'] += 100
        Game.client_update_players()
        update_player_list()
        print_state()
    else:
        Game.resume_guessing()

    self.GUESSING = false
    self.GUESSING_PLAYER = -1

    $btn_correct.disabled = true
    $btn_wrong.disabled = true
    $btn_next.disabled = false

func client_guess(id):
    if not self.GUESSING:
        self.GUESSING = true
        self.GUESSING_PLAYER = id
        _on_pause_pressed()
        update_player_list(id) # higlights player in list
        $btn_correct.disabled = false
        $btn_wrong.disabled = false
        $btn_next.disabled = true

func update_player_list(selected = -1):
    var list = $list_players
    var id
    list.clear()
    for player in Game.PLAYERS_LIST:
        id = list.add_item(str(Game.PLAYERS_LIST[player]['score']) + ' - ' + Game.PLAYERS_LIST[player]['name'])
        if selected == player:
            list.select(id)

func load_movie(id):
    Game.client_load_movie(id)
    var movie = Game.MOVIES[id]
    _on_pause_pressed()
    $label_details_text.text = movie['details']
    $label_name.text = movie['name']
    $img_movie.texture = movie['image']
    $AudioStreamPlayer.stream = movie['music']
    $ProgressBar.max_value = movie['music'].get_length()
