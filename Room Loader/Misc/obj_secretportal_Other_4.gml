with (obj_player)
{
	if (object_index != obj_player2 or global.coop)
	{
		// UTMT + CYOP code here
		var validPortal = false
		if global.cyop
			validPortal = (global.cyop_levelroom == global.cyop_secret[0] && other.instID == global.cyop_secret[1])
		else if (room == rm_utmtroom)
			validPortal = (other.instID == global.utmtSecretID)
		
		if (targetDoor == "S" && (secretportalID == other.id || validPortal))
		{
			x = other.x
			y = other.y
			roomstartx = x
			roomstarty = y
			with (obj_followcharacter)
			{
				x = other.x
				y = other.y
			}
			with (obj_pizzaface)
			{
				x = other.x
				y = other.y
			}
			
			other.sprite_index = spr_secretportal_close
			other.image_index = 0
			instance_destroy(other)
			instance_create(x, y, obj_secretportalstart)
		}
	}
}

if (ds_list_find_index(global.saveroom, id) != -1)
{
	active = 0
	sprite_index = spr_secretportal_close
	image_index = 0
	trace("portal active: false")
}

if global.solidbreak
{
	var platformX = x - (sprite_width / 2)
	var platformY = y + sprite_height - sprite_get_yoffset(sprite_index)
	var createPlatform = false
	if position_meeting(x, platformY, obj_solid)
		createPlatform = true
	
	if createPlatform
	{
		with (instance_create(platformX, platformY, obj_dynamicPlatform))
		{
			depth = 100
			image_xscale = other.sprite_width / 32
		}
	}
}