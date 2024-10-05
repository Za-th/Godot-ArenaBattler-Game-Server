extends Node

@onready var spawned_characters_node = get_parent().get_node("Main").get_node("Characters")

var ability_map:Dictionary = {
	# Visual is player node name
	"Visual": {
		"FirstAbility": {
			"Name": "Heal",
			"Cooldown": 8.0,
			"Value": 20
		},
		"SecondAbility": {
			"Name": "DamageBuff",
			"Cooldown": 10.0,
			"Value": 0.3,
			"Duration": 4
		},
		"ThirdAbility": {
			"Name": "Attack",
			"Cooldown": 1.0,
			"Value": -10.0
		}
	},
	
	"Rat": {
		"FirstAbility": {
			"Name": "Lightning",
			"Cooldown": 5.0,
			"Value": -40
		},
		"SecondAbility": {
			"Name": "SpeedDebuff",
			"Cooldown": 8.0,
			"Duration": 4.0,
			"Value": -0.4
		},
		"ThirdAbility": {
			"Name": "Stun",
			"Cooldown": 5.0,
			"Duration": 2
		}
	},
	
	"Bird": {
		"FirstAbility": {
			"Name": "Tornado",
			"Cooldown": 5.0,
			"Duration": 2.0
		},
		"SecondAbility": {
			"Name": "Push",
			"Cooldown": 5.0,
			"Value": 2.0
		},
		"ThirdAbility": {
			"Name": "Shield",
			"Cooldown": 6.0,
			"Duration": 3.0
		}
	},
	
	"Cat": {
		"FirstAbility": {
			"Name": "Bleed",
			"Cooldown": 7.0,
			"Value": -10,
			"Duration": 3.0
		},
		"SecondAbility": {
			"Name": "MultiAttack",
			"Cooldown": 5.0,
			"Value": -5,
			"Attacks": 15
		},
		"ThirdAbility": {
			"Name": "Hiss",
			"Cooldown": 15.0,
			"Duration": 4.0
		}
	},
	
	"Dog": {
		"FirstAbility": {
			"Name": "JumpAttack",
			"Cooldown": 8.0,
			"Value": -20
		},
		"SecondAbility": {
			"Name": "TailWhip",
			"Cooldown": 5.0,
			"Value": -40
		},
		"ThirdAbility": {
			"Name": "Charge",
			"Cooldown": 12.0,
			"Duration": 4.0,
			"Distance": 15
		}
	}
}


func used_ability(controller, character_name:String, ability:String, _player_id:int) -> void:
	var player_id:String = str(_player_id)
	var ability_data:Dictionary = ability_map[character_name.split(" ")[1]][ability]
	
	var kills:int = 0
	
	var character:Node3D = get_parent().get_node("Main").get_node("Characters").get_node(character_name)
	
	# TODO have some player feedback
	if character.ability_cooldown[ability] == true or character.stunned or character.disarmed or character.using_ability:
		return
	
	character.using_ability = true
	
	# use ability, damage values are affected by characters damage multiplier
	match ability_data["Name"]:
		"Heal":
			character.get_node("AbilityVisuals").heal()
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner == player_id:
							affected_hitbox.change_health(ability_data["Value"])
		"DamageBuff":
			character.get_node("AbilityVisuals").damage_buff()
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner == player_id:
							affected_hitbox.affect_damage_mult(ability_data["Value"], ability_data["Duration"])
		"Attack":
			character.get_node("AbilityVisuals").attack()
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner != player_id:
							if affected_hitbox.change_health(ability_data["Value"] * character.damage_mult):
								kills += 1
		
		"Lightning":
			character.get_node("AbilityVisuals").lightning()
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner != player_id:
							if affected_hitbox.change_health(ability_data["Value"] * character.damage_mult):
								kills += 1
		"SpeedDebuff":
			character.get_node("AbilityVisuals").speed_debuff()
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner != player_id:
							affected_hitbox.affect_speed_mult(ability_data["Value"], ability_data["Duration"])
		"Stun":
			character.get_node("AbilityVisuals").stun()
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner != player_id:
							affected_hitbox.stun(ability_data["Duration"])
		
		"Tornado":
			character.get_node("AbilityVisuals").tornado()
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner != player_id:
							affected_hitbox.knockup(ability_data["Duration"])
			await get_tree().create_timer(1).timeout
		"Push":
			character.get_node("AbilityVisuals").push()
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner != player_id:
							affected_hitbox.push(ability_data["Value"], character.global_rotation)
		"Shield":
			character.get_node("AbilityVisuals").shield()
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner == player_id:
							affected_hitbox.shield(ability_data["Duration"])
		
		"Bleed":
			character.get_node("AbilityVisuals").bleed()
			var current_closest:Area3D
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner != player_id:
							if current_closest == null:
								current_closest = affected_hitbox
							else:
								if affected_hitbox.global_position.distance_to(character.global_position) < current_closest.global_position.distance_to(character.global_position):
									current_closest = affected_hitbox
			if current_closest != null:
				current_closest.bleed(ability_data["Value"], ability_data["Duration"])
		"MultiAttack":
			character.get_node("AbilityVisuals").multi_attack()
			var attack:int = 0
			while attack < ability_data["Attacks"]:
				
				if !is_instance_valid(character): return
				
				var current_closest:Area3D
				for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
					if is_instance_valid(affected_hitbox):
						if affected_hitbox.name == "Hurtbox":
							if affected_hitbox.player_owner != player_id:
								if current_closest == null:
									current_closest = affected_hitbox
								else:
									if affected_hitbox.global_position.distance_to(character.global_position) < current_closest.global_position.distance_to(character.global_position):
										current_closest = affected_hitbox
				if current_closest != null:
					current_closest.change_health(ability_data["Value"])
				await get_tree().create_timer(0.2).timeout
				attack += 1
		"Hiss":
			character.get_node("AbilityVisuals").hiss()
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner != player_id:
							affected_hitbox.disarm(ability_data["Duration"])
		
		"JumpAttack":
			var current_furthest:Area3D
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner != player_id:
							if current_furthest == null:
								current_furthest = affected_hitbox
							else:
								if affected_hitbox.global_position.distance_to(character.global_position) > current_furthest.global_position.distance_to(character.global_position):
									current_furthest = affected_hitbox
			if current_furthest != null:
				character.jump_to(current_furthest.global_position)
				current_furthest.change_health(ability_data["Value"])
		"TailWhip":
			character.get_node("AbilityVisuals").tail_whip()
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner != player_id:
							if affected_hitbox.change_health(ability_data["Value"] * character.damage_mult):
								kills += 1
		"Charge":
			character.get_node("AbilityVisuals").charge()
			await get_tree().create_timer(0.7).timeout
			var affected_hitboxes:Array = []
			for affected_hitbox in character.get_node("AbilityHitboxes/" + ability_data["Name"]).get_overlapping_areas():
				if is_instance_valid(affected_hitbox):
					if affected_hitbox.name == "Hurtbox":
						if affected_hitbox.player_owner != player_id:
							affected_hitboxes.append(affected_hitbox)
			character.charge(ability_data["Distance"])
			for hitbox in affected_hitboxes:
				hitbox.stun(ability_data["Duration"])
		
		_: pass
	
	if kills > 0:
		get_tree().root.get_node("Main").IncreasePlayerKills(player_id, kills)
	
	controller.server_used_ability(character_name, ability)
	
	# put ability on cooldown
	character.put_ability_on_cooldown(ability, ability_data["Cooldown"])
	
	character.using_ability = false
