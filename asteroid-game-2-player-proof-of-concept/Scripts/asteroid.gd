extends RigidBody2D

const SPEED = 50.0
const LIFETIME = 5.0


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var sprite: AnimatedSprite2D
var frame = 0

func _ready():
	sprite = $AnimatedSprite2D

func reset():
	frame = 0
	

func asteroid_destroyed() -> void:
	sprite.play("default")