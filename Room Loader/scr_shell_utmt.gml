// UTMT commands for use with rt-shell

#region utmt_download
function sh_utmt_download(args)
{
	utmt_download()
}

function meta_utmt_download()
{
	return
	{
		description: "download UTMT-CLI for use with UTMT functions",
		hidden: false,
		deferred: false
	}
}
#endregion

#region utmt_exportrooms
function sh_utmt_exportrooms(args)
{
	if !file_exists("utmtcli/UndertaleModCli.exe")
		return "UTMT-CLI isn't present. Please download it first.";
	
	if (array_length(args) <= 1)
		return "You must specify a name for the room set.";
	
	var file = get_open_filename("GameMaker data file|*.win", "")
	if (file == "")
		return "No data file was specified.";
		
	var exportSprites = false
	if (array_length(args) > 2)
	{
		switch args[2]
		{
			case "true":
			case "1":
			case "yes":
				exportSprites = true
				break
		
			case "false":
			case "0":
			case "no":
				exportSprites = false
				break
		}
	}
	
	utmt_exportrooms(file, args[1], exportSprites)
}

function meta_utmt_exportrooms()
{
	return
	{
		description: "export rooms from data file",
		arguments: ["name", "<exportSprites bool>"],
		argumentDescriptions: ["room set name", "export tilesets and sprites (will take a while)"],
		hidden: false,
		deferred: false
	}
}
#endregion

#region utmt_exportsprites
function sh_utmt_exportsprites(args)
{
	if !file_exists("utmtcli/UndertaleModCli.exe")
		return "UTMT-CLI isn't present. Please download it first.";
	
	if (array_length(args) <= 1)
		return "You must specify a room set name.";
	if !utmt_roomset_exists(args[1])
		return "The specified room set doesn't exist.";
	
	var file = get_open_filename("GameMaker data file|*.win", "")
	if (file == "")
		return "No data file was specified.";
	
	utmt_exportsprites(file, args[1])
}

function meta_utmt_exportsprites()
{
	return
	{
		description: "export sprites from data file",
		arguments: ["name"],
		argumentDescriptions: ["room set name"],
		hidden: false,
		deferred: false
	}
}
#endregion

#region utmt_exporttilesets
function sh_utmt_exporttilesets(args)
{
	if !file_exists("utmtcli/UndertaleModCli.exe")
		return "UTMT-CLI isn't present. Please download it first.";
	
	if (array_length(args) <= 1)
		return "You must specify a room set name.";
	if !utmt_roomset_exists(args[1])
		return "The specified room set doesn't exist.";
	
	var file = get_open_filename("GameMaker data file|*.win", "")
	if (file == "")
		return "No data file was specified.";
	
	utmt_exporttilesets(file, args[1])
}

function meta_utmt_exporttilesets()
{
	return
	{
		description: "export tilesets from data file",
		arguments: ["name"],
		argumentDescriptions: ["room set name"],
		hidden: false,
		deferred: false
	}
}
#endregion

#region utmt_delete_export
function sh_utmt_delete_export(args)
{
	if (array_length(args) <= 1)
		return "You must specify a room set name.";
	if !utmt_roomset_exists(args[1])
		return "The specified room set doesn't exist.";
	
	utmt_delete_export(args[1])
	return "Deleted room set " + args[1];
}

function meta_utmt_delete_export()
{
	return
	{
		description: "delete exported room set",
		arguments: ["name"],
		argumentDescriptions: ["room set name"],
		hidden: false,
		deferred: false
	}
}
#endregion

#region utmt_setroomset
function sh_utmt_setroomset(args)
{
	if (array_length(args) <= 1)
		return "You must specify a room set name.";
	
	utmt_setroomset(args[1])
	return "Room set is now " + args[1];
}

function meta_utmt_setroomset()
{
	return
	{
		description: "set current room set",
		arguments: ["name"],
		argumentDescriptions: ["room set name"],
		hidden: false,
		deferred: false
	}
}
#endregion

#region utmt_gotoroom
function sh_utmt_gotoroom(args)
{
	if (array_length(args) <= 1)
		return "You must specify a room name.";
	
	var roomname = args[1]
	if !utmt_room_exists(global.utmtRoomSet, roomname)
		return "The specified room doesn't exist.";
		
	var door = -4
	if (array_length(args) > 2)
		door = args[2]
			
	with (obj_player)
	{
		targetRoom = roomname
		if (door != -4)
			targetDoor = door
	}
		
	utmt_goto_room(roomname)
	self.close()
}

function meta_utmt_gotoroom()
{
	return
	{
		description: "go to room in room set",
		arguments: ["name", "<door>"],
		suggestions: ["", ["A", "B", "C", "D", "E", "F", "G"]],
		argumentDescriptions: ["room name", "door targets"],
		hidden: false,
		deferred: false
	}
}
#endregion

#region utmt_listrooms
function sh_utmt_listrooms(args)
{
	if (global.utmtRoomSet == "")
		return "You haven't set the current room set.";
	
	var roomString = ""
	var file = file_find_first(concat("exports/", global.utmtRoomSet, "/Rooms/*.json"), 0)
	while (file != "")
	{
		roomString += string_replace_all(file, filename_ext(file), "") + "\n"
		file = file_find_next()
	}
	file_find_close()
	
	return roomString;
}

function meta_utmt_listrooms()
{
	return
	{
		description: "list rooms in room set",
		hidden: false,
		deferred: false
	}
}
#endregion

#region utmt_resetrooms
function sh_utmt_resetrooms(args)
{
	utmt_roomstate_reset()
	return "UTMT room states have been reset.";
}

function meta_utmt_resetrooms()
{
	return
	{
		description: "reset UTMT room states",
		hidden: false,
		deferred: false
	}
}
#endregion

#region utmt_genfixes
function sh_utmt_genfixes(args)
{
	if (global.utmtRoomSet == "")
		return "You haven't set the current room set.";
	
	utmt_generate_fixes()
	return "Generated fixes.txt for the current room set.";
}

function meta_utmt_genfixes()
{
	return
	{
		description: "generate fixes.txt for current room set",
		hidden: false,
		deferred: false
	}
}
#endregion

#region utmt_opendir
function sh_utmt_opendir(args)
{
	if (global.utmtRoomSet == "")
		return "You haven't set the current room set.";
	
	open_directory(concat(game_save_id, "exports\\", global.utmtRoomSet))
	return "A file browser window should have opened.";
}

function meta_utmt_opendir()
{
	return
	{
		description: "open current room set directory",
		hidden: false,
		deferred: false
	}
}
#endregion