extends Area3D

@export var player_owner:String

# this area 3d exists as the characters hurtbox and is returned when it is intersecting the hitbox of a used ability,
# its parent node handles all stats and affects on the character so functions needs to hand up values that abilities affect on the player

func _ready():
	player_owner = get_parent().name.split(" ")[0]

func change_health(value:float) -> bool:
	return get_parent().change_health(value)

func affect_damage_mult(value:float, duration:float) -> void:
	get_parent().affect_damage_mult(value, duration)

func stun(time:float) -> void:
	get_parent().stun(time)

func affect_speed_mult(value:float, duration:float):
	get_parent().affect_speed_mult(value, duration)

func knockup(duration:float):
	get_parent().knockup(duration)

func push(distance:float, direction:Vector3):
	get_parent().push(distance, direction)

func shield(duration:float):
	get_parent().shield(duration) 

func bleed(value:float, duration:float):
	get_parent().bleed(value, duration)

func disarm(duration:float):
	get_parent().disarm(duration)
