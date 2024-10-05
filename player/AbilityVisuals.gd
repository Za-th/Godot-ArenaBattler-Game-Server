extends Node

# Player abilities
@rpc("authority", "call_remote")
func heal():
	rpc("heal")

@rpc("authority", "call_remote")
func damage_buff():
	rpc("damage_buff")

@rpc("authority", "call_remote")
func attack():
	rpc("attack")


# Rat abilities
@rpc("authority", "call_remote")
func lightning():
	rpc("lightning")

@rpc("authority", "call_remote")
func speed_debuff():
	rpc("speed_debuff")

@rpc("authority", "call_remote")
func stun():
	rpc("stun")


# Bird abilities
@rpc("authority", "call_remote")
func tornado():
	rpc("tornado")

@rpc("authority", "call_remote")
func push():
	rpc("push")

@rpc("authority", "call_remote")
func shield():
	rpc("shield")


# Cat abilities
@rpc("authority", "call_remote")
func bleed():
	rpc("bleed")

@rpc("authority", "call_remote")
func multi_attack():
	rpc("multi_attack")

@rpc("authority", "call_remote")
func hiss():
	rpc("hiss")


# Dog abilities
@rpc("authority", "call_remote")
func tail_whip():
	rpc("tail_whip")

@rpc("authority", "call_remote")
func charge():
	rpc("charge")


# effects
@rpc("authority", "call_remote")
func damage_buffed(duration:float):
	rpc("damage_buffed", duration)

@rpc("authority", "call_remote")
func speed_debuffed(duration:float):
	rpc("speed_debuffed", duration)

@rpc("authority", "call_remote")
func stunned(duration:float):
	rpc("stunned", duration)

@rpc("authority", "call_remote")
func knocked_up(duration:float):
	rpc("knocked_up", duration)

@rpc("authority", "call_remote")
func shielded(duration:float):
	rpc("shielded", duration)

@rpc("authority", "call_remote")
func bleeding(duration:float):
	rpc("bleeding", duration)

@rpc("authority", "call_remote")
func disarmed(duration:float):
	rpc("disarmed", duration)
