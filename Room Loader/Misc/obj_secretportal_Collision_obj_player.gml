if (active && sprite_index != spr_secretportal_open && (!instance_exists(obj_jumpscare)) && ds_list_find_index(global.saveroom, id) == -1)
{
	if (sprite_index != spr_secretportal_close)
	{
		sprite_index = spr_secretportal_close
		image_index = 0
		fmod_play(global.snd_secretenter)
	}
	if (!touched && !soundtest && room != tower_soundtestlevel && !instance_exists(obj_randomsecret))
	{
		if secret
			notification_push(notifs.secret_exit, [room])
		else
			notification_push(notifs.secret_enter, [room, targetRoom])
		
		if instance_exists(obj_music)
		{
			with (obj_music)
			{
				if (!secret)
				{
					if (global.cyop)
					{
						savedmusicpos = fmod_channel_get_position(cyop_channel, FMOD_TIMEUNIT.MS)
						var _length = fmod_sound_get_length(cyop_music, FMOD_TIMEUNIT.MS)
						cyop_secretpos = get_music_pos(savedmusicpos, _length)
					}
				
					secret = true
					secretend = false
				}
				else
				{
					secretend = true
					secret = false
				}
			}
		}
	}
	
	// UTMT code here (and CYOP too I guess)
	if (!touched && !secret)
	{
		if global.cyop
			global.cyop_secret = [global.cyop_levelroom, instID]
		else if (room == rm_utmtroom)
			global.utmtSecretID = instID
	}
	
	playerid = other.id
	other.ghostdash = false
	other.ghostpepper = 0
	other.x = x
	other.y = (y - 30)
	other.vsp = 0
	other.hsp = 0
	other.cutscene = 1
	if (!touched)
	{
		other.superchargedeffectid = -4
		if (other.state != states.knightpep && other.state != states.knightpepslopes && other.state != states.knightpepbump && other.state != states.firemouth)
		{
			if (!other.isgustavo)
				other.sprite_index = other.spr_hurt
			else
				other.sprite_index = spr_player_ratmounthurt
			other.image_speed = 0.35
		}
		if (other.state == states.knightpepslopes)
		{
			other.sprite_index = other.spr_knightpepfall
			other.state = states.knightpep
			other.hsp = 0
			other.vsp = 0
		}
		
		if (!secret)
			global.secretenter = true
		
		other.tauntstoredstate = other.state
		other.tauntstoredmovespeed = other.movespeed
		other.tauntstoredhsp = other.hsp
		other.tauntstoredvsp = other.vsp
		other.tauntstoredsprite = other.sprite_index
		other.state = states.secretenter
	}
	touched = true
	with (obj_heatafterimage)
		visible = false
	instance_destroy(obj_superchargeeffect)
}
