///@description Go To Room
if instance_exists(obj_player)
{
	if is_string(obj_player1.targetRoom)
	{
		if global.cyop
		{
			global.cyop_levelroom = obj_player1.targetRoom
			global.cyop_roomdata = cyop_get_level_roomdata()
		
			cyop_goto_level()
		}
		else if (room == rm_utmtroom)
			utmt_goto_room(obj_player1.targetRoom)
			
		with (obj_player)
		{
			if (state == states.ejected || state == states.policetaxi)
			{
				visible = true
				state = states.normal
			}
		}
	}
	else
	{
		if (targetRoom != -4)
			scr_room_goto(targetRoom)
		else
		{
			var playerRoom = scr_room_get(obj_player1.targetRoom)
			if (room != playerRoom || roomreset)
			{
				scr_room_goto(obj_player1.targetRoom)
				with (obj_player)
				{
					if (state == states.ejected || state == states.policetaxi)
					{
						visible = true
						state = states.normal
					}
				}
			}
			
			if global.coop
			{
				with (obj_player2)
				{
					if instance_exists(obj_coopplayerfollow)
						state = states.gotoplayer
				}
			}
		}
	}
}