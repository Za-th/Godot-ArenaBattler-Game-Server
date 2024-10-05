extends Node

var player_id:int
var is_player:bool

@onready var healthbar:TextureProgressBar = $Healthbar/SubViewport/TextureProgressBar

# default values
var max_health:float = 100
@export var health:float = 100
var move_speed:float = 5.0
var turn_speed:float = PI*2
@export var ability_cooldown:Dictionary = {"FirstAbility": false, "SecondAbility": false, "ThirdAbility": false}
@export var damage_mult:float = 1.0
var speed_mult:float = 1.0
@export var stunned:bool = false
var spinning:bool = false
var shielded:bool = false
@export var disarmed:bool = false
@export var using_ability:bool = false

var pathing:bool = false
var index:int = 0
var path:PackedVector3Array


func _ready() -> void:
	# adjust graphics to account for navmesh
	self.global_position.y = 0.5
	
	var character_name:String = name.split(" ")[1]
	health = CharacterStats.stats[character_name]["Health"]
	max_health = health
	move_speed = CharacterStats.stats[character_name]["Speed"]
	turn_speed = CharacterStats.stats[character_name]["Turn Speed"]
	
	player_id = name.split(" ")[0].to_int()
	
	is_player = name.split(" ")[1] == "Visual"


func start_moving(_path:PackedVector3Array) -> void:
	if stunned or using_ability:
		return
	if pathing:
		stop_moving()
	path = _path
	pathing = true


func stop_moving() -> void:
	pathing = false
	index = 0


func pause_moving(time:int) -> void:
	pathing = false
	await get_tree().create_timer(time).timeout
	pathing = true


func _process(delta) -> void:
	if spinning:
		self.global_position.y += 0.005
		self.global_rotation.y += 0.1
	
	if using_ability or stunned: return
	
	if (pathing):
		if (index < path.size()):
			# how far the player will move
			var step:float = delta * move_speed * speed_mult
			
			# get direction of next path point
			var direction:Vector3 = path[index] - self.global_position
		
			# if the next step would go over path point move to point and start on next one
			if (step > direction.length()):
				step = direction.length()
				index += 1
			
			# change the position of the player
			var diff:Vector3 = direction.normalized() * step
			self.global_position += diff
			
			# rotate player towards next path point
			self.rotation.y = lerp_angle(self.rotation.y, atan2(-direction.x,-direction.z), turn_speed*delta)
			
		else:
			# pathing finished
			stop_moving()


func change_health(value:float) -> bool:
	if value < 0 and shielded:
		return false
	
	health += value
	health = min(health, max_health)
	if health <= 0:
		if is_player:
			get_tree().root.get_node("Main").RespawnPlayer(str(player_id))
			return true
		else:
			get_tree().root.get_node("Main").RemoveCreature(str(player_id), name.split(" ")[1])
			return false
	# health in healthbar is percentage
	healthbar.update_health(health/max_health * 100)
	return false


func affect_damage_mult(value:float, duration:float) -> void:
	if value > 0:
		get_node("AbilityVisuals").damage_buffed(duration)
	damage_mult += value
	await get_tree().create_timer(duration).timeout
	damage_mult -= value


func put_ability_on_cooldown(ability:String, time:float):
	ability_cooldown[ability] = true
	await get_tree().create_timer(time).timeout
	ability_cooldown[ability] = false


func reset_health() -> void:
	health = max_health
	# health in healthbar is percentage
	healthbar.update_health(100)


func stun(duration:float) -> void:
	get_node("AbilityVisuals").stunned(duration)
	stop_moving()
	stunned = true
	await get_tree().create_timer(duration).timeout
	stunned = false


func affect_speed_mult(value:float, duration:float):
	if value < 0:
		get_node("AbilityVisuals").speed_debuffed(duration)
	speed_mult += value
	await get_tree().create_timer(duration).timeout
	speed_mult -= value


func knockup(duration:float):
	get_node("AbilityVisuals").knocked_up(duration)
	stun(duration)
	spinning = true
	await get_tree().create_timer(duration).timeout
	spinning = false
	self.global_position.y = 0.5


func push(distance:float, direction:Vector3):
	var base_vector = Vector3(0,0,-distance)
	self.global_position += Quaternion.from_euler(direction) * base_vector


func jump_to(position:Vector3):
	stop_moving()
	# TODO visual teleport
	self.global_position = position
	self.global_position.y += 0.7


func shield(duration:float):
	get_node("AbilityVisuals").shielded(duration)
	shielded = true
	await get_tree().create_timer(duration).timeout
	shielded = false


func charge(distance:int):
	var base_vector = Vector3(0,0,-distance)
	self.global_position += Quaternion.from_euler(self.global_rotation) * base_vector


func bleed(value:float, duration:float):
	get_node("AbilityVisuals").bleeding(duration)
	var time:int = 0
	while time < duration:
		# bleed cant kill1
		if health < -1*value:
			return
		change_health(value)
		await get_tree().create_timer(1).timeout
		time += 1


func disarm(duration:float):
	get_node("AbilityVisuals").disarmed(duration)
	disarmed = true
	await get_tree().create_timer(duration).timeout
	disarmed = false
