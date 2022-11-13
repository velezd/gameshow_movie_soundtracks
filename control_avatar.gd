extends Control

var option = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    $btn_avatar_left.connect('pressed', _on_left_pressed)
    $btn_avatar_right.connect('pressed', _on_right_pressed)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_left_pressed():
    next_avatar(true)

func _on_right_pressed():
    next_avatar()

func next_avatar(reverse=false):
    if reverse:
        if self.option == 0: return
        self.option -= 1
    else:
        if self.option == 10: return
        self.option += 1
    
    $texture_avatar.texture = Game.AVATARS[self.option]
