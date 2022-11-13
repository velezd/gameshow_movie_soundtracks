extends Node

var SERVER_PORT = 4242
var PLAYERS_LIST = {}
# Testing player list
var PLAYERS_LIST_test = {
    101: {'name': 'Test', 'score': 100, 'avatar': 0},
    102: {'name': 'Zdenek', 'score': 0, 'avatar': 1},
    103: {'name': 'Pavel', 'score': 900, 'avatar': 2},
    104: {'name': 'Honza', 'score': 4500, 'avatar': 3},
    105: {'name': 'Peter', 'score': 100, 'avatar': 4},
    106: {'name': 'Ludmila', 'score': 1600, 'avatar': 5},
    107: {'name': 'Trotlobot', 'score': 700, 'avatar': 6},
    108: {'name': 'Lucka', 'score': 200, 'avatar': 7},
    109: {'name': 'Jan', 'score': 4500, 'avatar': 8},
    110: {'name': 'FooBar', 'score': 500, 'avatar': 9}
}

var AVATARS = [preload("res://textures/avatars/1.png"),
               preload("res://textures/avatars/2.png"),
               preload("res://textures/avatars/3.png"),
               preload("res://textures/avatars/4.png"),
               preload("res://textures/avatars/5.png"),
               preload("res://textures/avatars/6.png"),
               preload("res://textures/avatars/7.png"),
               preload("res://textures/avatars/8.png"),
               preload("res://textures/avatars/9.png"),
               preload("res://textures/avatars/10.png"),
               preload("res://textures/avatars/11.png")]

var MOVIES = [
    {'name': 'Test Movie 1',
     'details': 'Director: Direcor 1\nComposer: Composer 1\nYear: 2022',
     'image': preload("res://textures/posters/test_1.png"),
     'music': preload("res://music/test_1.ogg")},
    {'name': 'Test Movie 2',
     'details': 'Director: Direcor 2\nComposer: Composer 2\nYear: 2023',
     'image': preload("res://textures/posters/test_2.png"),
     'music': preload("res://music/test_2.ogg")},
]

var CURRENT_MOVIE = 0

func i_know():
    rpc_id(1, '_i_know')

@rpc(any_peer)
func _i_know():
    $/root/main/host.client_guess(multiplayer.get_remote_sender_id())
    rpc('stop_guessing')

func client_load_movie(id):
    rpc('_client_load_movie', id)

@rpc
func _client_load_movie(id):
    $/root/main/client.hide_movie()
    $/root/main/client.load_movie(id)

func client_play_music():
    rpc('_client_play_music')

@rpc
func _client_play_music():
    if $/root/main/client/AudioStreamPlayer.stream_paused:
        $/root/main/client/AudioStreamPlayer.stream_paused = false
    else:
        $/root/main/client/AudioStreamPlayer.play()

func client_pause_music():
    rpc('_client_pause_music')

@rpc
func _client_pause_music():
    $/root/main/client/AudioStreamPlayer.stream_paused = true

func client_update_players():
    rpc('_client_update_players', PLAYERS_LIST)

@rpc
func _client_update_players(players):
    self.PLAYERS_LIST = players
    $/root/main/client.update_scores()

func client_show_movie():
    rpc('_client_show_movie')

@rpc
func _client_show_movie():
    $/root/main/client.show_movie()

@rpc
func stop_guessing():
    $/root/main/client.stop_guessing()

func resume_guessing():
    rpc('_resume_guessing')

@rpc
func _resume_guessing():
    $/root/main/client.resume_guessing()

func show_winners():
    rpc('_show_winners')

@rpc
func _show_winners():
    # Add the next level
    var next_level = load('res://end.tscn').instantiate()
    $/root/main.add_child(next_level)
