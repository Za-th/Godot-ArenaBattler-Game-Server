extends Node

# default values
var move_speed:float = 10.0
var turn_speed:float = PI*2
var pathing:bool = false
var index:int = 0
var path:PackedVector3Array


# adjust graphics to account for navmesh
func _ready() -> void:
	self.global_position.y = 0.5


func start_moving(_path:PackedVector3Array) -> void:
	if pathing:
		stop_moving()
	path = _path
	pathing = true


func stop_moving() -> void:
	pathing = false
	index = 0


func _process(delta) -> void:
	if (pathing):
		if (index < path.size()):
			# how far the player will move
			var step:float = delta * move_speed
			
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
