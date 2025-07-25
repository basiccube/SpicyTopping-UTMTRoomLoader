global.utmtDownloadProgress = 0
global.utmtRoomSet = ""
global.utmtRoomName = ""
global.utmtRoom = -4
global.utmtSprites = ds_map_create()
global.utmtTilesets = ds_map_create()
global.utmtHasSprites = false

global.utmtOldTimestamp = 1640988000
global.utmtTimestamp = 0
global.utmtFixes =
{
	visibleladders : false,
	oldtilesets : false,
	ignoretiledepth : false,
	minijohnescapeonly : false,
	disablesecrettriggers : false,
	disabletvtriggers : false,
}

function utmt_initmaps()
{
	// Get UTMT object replacement map
	global.utmtObjectMap = -4
	if file_exists("spicytopping/utmtobjects.json")
		global.utmtObjectMap = json_parse(file_text_read_all("spicytopping/utmtobjects.json"))
	
	// Get UTMT tileset replacement map
	global.utmtTilesetMap = -4
	if file_exists("spicytopping/utmttilesets.json")
		global.utmtTilesetMap = json_parse(file_text_read_all("spicytopping/utmttilesets.json"))
	
	// Get UTMT tileset replacement map for older builds
	global.utmtOldTilesetMap = -4
	if file_exists("spicytopping/utmtoldtilesets.json")
		global.utmtOldTilesetMap = json_parse(file_text_read_all("spicytopping/utmtoldtilesets.json"))
}

// Downloads the command line version of UndertaleModTool and all other required files
function utmt_download()
{
	var installStage = 0
	if (file_exists("utmtcli/utmtcli.zip") && !file_exists("utmtcli/UndertaleModCli.exe"))
		installStage = 1
	else if file_exists("utmtcli/UndertaleModCli.exe")
		installStage = 2
	
	switch installStage
	{
		case 0:
			// Function for determining the download progress
			var finishfunc = function()
			{
				global.utmtDownloadProgress++
				if (global.utmtDownloadProgress >= 7)
					utmt_download()
			}
			global.utmtDownloadProgress = 0
			
			// Print initial text to in-game console
			with (obj_shell)
			{
				array_push(output, "Please wait while UTMT-CLI downloads...")
				if conhost_is_allocated()
					array_push(output, "Check the debug console window for more info.")
			}
			
			// Download UTMT itself and the scripts required
			download_file("https://github.com/UnderminersTeam/UndertaleModTool/releases/download/0.8.2.0/UTMT_CLI_v0.8.2.0-Windows.zip", "utmtcli/utmtcli.zip", finishfunc)
			download_file("https://github.com/basiccube/SpicyTopping-Misc/raw/refs/heads/main/ExportRooms.csx", "utmtcli/scripts/ExportRooms.csx", finishfunc)
			download_file("https://github.com/basiccube/SpicyTopping-Misc/raw/refs/heads/main/ExportInfo.csx", "utmtcli/scripts/ExportInfo.csx", finishfunc)
			download_file("https://github.com/basiccube/SpicyTopping-Misc/raw/refs/heads/main/ExportSprites.csx", "utmtcli/scripts/ExportSprites.csx", finishfunc)
			download_file("https://github.com/basiccube/SpicyTopping-Misc/raw/refs/heads/main/ExportTilesets.csx", "utmtcli/scripts/ExportTilesets.csx", finishfunc)
			
			// Pull UTMT definitions for PT
			download_file("https://github.com/azphina/PizzaTowerGameSpecificData/raw/refs/heads/main/GameSpecificData/Underanalyzer/pizzatower.json", "utmtcli/GameSpecificData/Underanalyzer/pizzatower.json", finishfunc)
			download_file("https://github.com/basiccube/SpicyTopping-Misc/raw/refs/heads/main/Definitions/pizzatower.json", "utmtcli/GameSpecificData/Definitions/pizzatower.json", finishfunc)
			break
			
		case 1:
			// Extract the utmtcli.zip file and then delete it after that
			print("Unzipping UTMT-CLI...")
			
			var result = zip_unzip("utmtcli/utmtcli.zip", "utmtcli/")
			if (result <= 0)
			{
				file_delete("utmtcli/utmtcli.zip")
				with (obj_shell)
					array_push(output, "Failed to unzip UTMT-CLI. Please try downloading again.")
				print("Failed to unzip UTMT-CLI.")
			}
			else
			{
				print("Cleaning up...")
				file_delete("utmtcli/utmtcli.zip")
				
				with (obj_shell)
					array_push(output, "Download complete! You can now use the UTMT specific functions.")
				print("UTMT-CLI download complete! You may now use the functions that make use of it.")
			}
			break
			
		case 2:
			// It's already installed, why do you want to install it again?
			with (obj_shell)
				array_push(output, "UTMT-CLI is already installed!")
			print("UTMT-CLI is already installed!")
			break
	}
}

// Executes a UTMT script on the specified data file
// Uses libxprocess for running the executable
function utmt_executescript(datafile, scriptfile)
{
	var path = concat(game_save_id, "\\utmtcli")
	var process = ProcessExecute(concat(path, "\\UndertaleModCli.exe load \"", datafile, "\" -s \"", path, "\\scripts\\", scriptfile, "\""))
	var processOutput = ExecutedProcessReadFromStandardOutput(process)
	print(processOutput)
}

// Exports rooms from a data file
// Can optionally specify to also export sprites and tilesets
function utmt_exportrooms(datafile, setname, exportsprites = false)
{
	with (obj_shell)
		array_push(output, concat("Exporting room data from ", filename_name(datafile)))
	print("Exporting room data from ", filename_name(datafile))
	utmt_executescript(datafile, "ExportRooms.csx")
	
	var basePath = concat(game_save_id, "/utmtcli/ExportedRooms/")
	var newPath = concat("exports/", setname, "/")
	if !directory_exists(basePath)
	{
		error("Room export failed.")
		with (obj_shell)
			array_push(output, "Room export failed.")
		exit;
	}
	
	// Get data file name (ex. PizzaTower_GM2) and UNIX timestamp
	// Will be used for enabling the old build room fixes
	print("Getting name and timestamp")
	utmt_executescript(datafile, "ExportInfo.csx")
	
	// Copy everything from the folder where it exported the rooms
	print("Copying room data files to room set directory ", setname)
	var dirs = []
	var dir = file_find_first(concat(basePath, "*.*"), fa_directory)
	while (dir != "")
	{
		array_push(dirs, dir)
		dir = file_find_next()
	}
	file_find_close()
	
	for (var i = 0; i < array_length(dirs); i++)
	{
		var path = concat(basePath, dirs[i], "/")
		var targetpath = concat(newPath, dirs[i], "/")
		
		var file = file_find_first(concat(path, "*.*"), 0)
		while (file != "")
		{
			file_copy(concat(path, file), concat(targetpath, file))
			file = file_find_next()
		}
		file_find_close()
	}
	
	// Copy the name and timestamp files
	file_copy(concat(basePath, "timestamp.txt"), concat(newPath, "timestamp.txt"))
	file_copy(concat(basePath, "name.txt"), concat(newPath, "name.txt"))
	
	print("Deleting temp directory")
	directory_destroy(basePath)
	
	// Export sprites and tilesets if specified
	if exportsprites
	{
		utmt_exportsprites(datafile, setname)
		utmt_exporttilesets(datafile, setname)
	}
	
	// Set current room set
	utmt_setroomset(setname)
	
	with (obj_shell)
		array_push(output, "Room export complete. Current room set has been set to " + setname)
	print("Room export complete. Current room set has been set to ", setname)
	print("Timestamp: ", global.utmtTimestamp)
}

// Export sprites and copy to the room set directory
function utmt_exportsprites(datafile, setname)
{
	print("Exporting sprites (this will take a while)")
	utmt_executescript(datafile, "ExportSprites.csx")
	
	var spritesBasePath = concat(game_save_id, "/utmtcli/ExportedSprites/")
	var spritesNewPath = concat("exports/", setname, "/Sprites/")
	
	print("Copying sprites to room set directory")
	var sprite = file_find_first(concat(spritesBasePath, "*.*"), 0)
	while (sprite != "")
	{
		file_copy(concat(spritesBasePath, sprite), concat(spritesNewPath, sprite))
		sprite = file_find_next()
	}
	file_find_close()
	
	print("Deleting sprites temp directory")
	directory_destroy(spritesBasePath)
}

// Export tilesets and copy to the room set directory
function utmt_exporttilesets(datafile, setname)
{
	print("Exporting tilesets")
	utmt_executescript(datafile, "ExportTilesets.csx")
	
	var tilesetsBasePath = concat(game_save_id, "/utmtcli/ExportedTilesets/")
	var tilesetsNewPath = concat("exports/", setname, "/Tilesets/")
	
	print("Copying tilesets to room set directory")
	var tileset = file_find_first(concat(tilesetsBasePath, "*.*"), 0)
	while (tileset != "")
	{
		file_copy(concat(tilesetsBasePath, tileset), concat(tilesetsNewPath, tileset))
		tileset = file_find_next()
	}
	file_find_close()
	
	print("Deleting tilesets temp directory")
	directory_destroy(tilesetsBasePath)
}

// Delete room set (if it exists)
function utmt_delete_export(setname)
{
	if !utmt_roomset_exists(setname)
	{
		print("Room set ", setname, " doesn't exist")
		exit;
	}
	
	if (global.utmtRoomSet == setname)
		global.utmtRoomSet = ""
	directory_destroy(concat("exports/", setname))
}

// Set current room set to the one specified
function utmt_setroomset(setname)
{
	if !utmt_roomset_exists(setname)
	{
		print("Room set ", setname, " doesn't exist")
		exit;
	}
	
	global.utmtRoomSet = setname
	global.utmtTimestamp = utmt_get_timestamp(setname)
	global.utmtHasSprites = directory_exists(concat("exports/", setname, "/Sprites/"))
	utmt_clear_fixes()
	
	// Parse fixes.txt file if it exists
	// If it doesn't, create it
	if !utmt_parse_fixes()
		utmt_generate_fixes()
}

// Reset all fixes
function utmt_clear_fixes()
{
	var fixes = variable_struct_get_names(global.utmtFixes)
	var fixesLength = array_length(fixes)
	for (var i = 0; i < fixesLength; i++)
		variable_struct_set(global.utmtFixes, fixes[i], false)
}

// Generates the fixes.txt file for the current room set
function utmt_generate_fixes()
{
	utmt_clear_fixes()
	
	var name = utmt_get_name(global.utmtRoomSet)
	if (string_pos("PizzaTower_Demo3", name) != 0)
	{
		print("UTMT fixes enabled: Demo 3")
		global.utmtFixes.visibleladders = true
		global.utmtFixes.oldtilesets = true
		global.utmtFixes.minijohnescapeonly = true
		global.utmtFixes.ignoretiledepth = true
	}
	else if (string_pos("Pizza_Tower_Plus_Mod", name) != 0)
	{
		print("UTMT fixes enabled: '19 Plus")
		global.utmtFixes.oldtilesets = true
		global.utmtFixes.ignoretiledepth = true
	}
	else if (global.utmtTimestamp < global.utmtOldTimestamp)
	{
		print("UTMT fixes enabled: Old Build")
		global.utmtFixes.visibleladders = true
		global.utmtFixes.oldtilesets = true
		global.utmtFixes.minijohnescapeonly = true
		global.utmtFixes.ignoretiledepth = true
		global.utmtFixes.disablesecrettriggers = true
		global.utmtFixes.disabletvtriggers = true
	}
	
	var initialText = "# This file specifies any fixes that\n"
	initialText += "# will be enabled for this room set.\n"
	initialText += "# To disable a fix, simply comment it out via\n"
	initialText += "# the # character at the start of a line.\n\n"
	
	var fixString = ""
	var fixNames = variable_struct_get_names(global.utmtFixes)
	var fixNameLength = array_length(fixNames)
	for (var i = 0; i < fixNameLength; i++)
		fixString += (variable_struct_get(global.utmtFixes, fixNames[i]) ? "" : "#") + fixNames[i] + "\n"
		
	var path = concat("exports/", global.utmtRoomSet, "/fixes.txt")
	if file_exists(path)
		file_delete(path)
		
	var file = file_text_open_write(path)
	file_text_write_string(file, initialText + fixString)
	file_text_close(file)
	print("Generated fixes.txt for room set ", global.utmtRoomSet)
}

// Parses the fixes.txt file from the current room set
function utmt_parse_fixes()
{	
	var path = concat("exports/", global.utmtRoomSet, "/fixes.txt")
	if !file_exists(path)
		return false;
	
	var fixes = []
	var file = file_text_open_read(path)
	while !file_text_eof(file)
	{
		var line = file_text_readln(file)
		line = string_replace_all(line, "\r", "")
		line = string_replace_all(line, "\n", "")
		
		if (string_char_at(line, 1) != "#" && line != "")
			array_push(fixes, line)
	}
	file_text_close(file)
	
	var fixesLength = array_length(fixes)
	for (var i = 0; i < fixesLength; i++)
	{
		if !variable_struct_exists(global.utmtFixes, fixes[i])
			continue;
		
		variable_struct_set(global.utmtFixes, fixes[i], true)
	}
	
	print("Loaded fixes.txt for room set ", global.utmtRoomSet)
	return true;
}

// Get timestamp of specified room set
function utmt_get_timestamp(setname)
{
	if !utmt_roomset_exists(setname)
	{
		print("Room set ", setname, " doesn't exist")
		return global.utmtOldTimestamp;
	}
	
	var path = concat("exports/", setname, "/timestamp.txt")
	if !file_exists(path)
		return global.utmtOldTimestamp;
	
	var timestampFile = file_text_read_all(path)
	return real(timestampFile);
}

// Get data file name of specified room set
function utmt_get_name(setname)
{
	if !utmt_roomset_exists(setname)
	{
		print("Room set ", setname, " doesn't exist")
		return "";
	}
	
	var path = concat("exports/", setname, "/name.txt")
	if !file_exists(path)
		return "";
	
	var nameString = file_text_read_all(path)
	return nameString;
}

// Add sprite gif from current room set to sprite map
function utmt_add_sprite(spritename)
{
	if !utmt_roomset_exists(global.utmtRoomSet)
	{
		print("Room set ", global.utmtRoomSet, " doesn't exist")
		return undefined;
	}
	
	var path = concat("exports/", global.utmtRoomSet, "/Sprites/", spritename, ".gif")
	if !file_exists(path)
	{
		print("Specified sprite doesn't exist: ", spritename)
		return undefined;
	}
	
	print("Adding sprite ", spritename)
	
	// Get origin data if present
	var originX = 0
	var originY = 0
	if file_exists(string_replace_all(path, ".gif", ".json"))
	{
		print("Found sprite origins for ", spritename)
		var originFile = json_parse(file_text_read_all(string_replace_all(path, ".gif", ".json")))
		originX = originFile.OriginX
		originY = originFile.OriginY
	}
	
	// Add sprite using sprite_add_gif extension
	var sprite = sprite_add_gif(path, originX, originY)
	return sprite;
}

// Add tileset from current room set to tileset map
function utmt_add_tileset(tilesetname)
{
	if !utmt_roomset_exists(global.utmtRoomSet)
	{
		print("Room set ", global.utmtRoomSet, " doesn't exist")
		return undefined;
	}
	
	var path = concat("exports/", global.utmtRoomSet, "/Tilesets/", tilesetname, ".png")
	if !file_exists(path)
	{
		print("Specified tileset doesn't exist: ", tilesetname)
		return undefined;
	}
	
	print("Adding tileset ", tilesetname)
	
	var tileset =
	{
		sprite : -4,
		
		width : 32,
		height : 32,
		borderX : 2,
		borderY : 2,
	}
	
	// Add tileset sprite
	tileset.sprite = sprite_add(path, 1, false, false, 0, 0)
	
	// Get tileset info if present
	if file_exists(string_replace_all(path, ".png", ".json"))
	{
		print("Found tileset info for ", tilesetname)
		
		var infoFile = json_parse(file_text_read_all(string_replace_all(path, ".png", ".json")))
		tileset.width = infoFile.Width
		tileset.height = infoFile.Height
		tileset.borderX = infoFile.BorderX
		tileset.borderY = infoFile.BorderY
	}
	
	return tileset;
}

// Check if room set exists
function utmt_roomset_exists(setname)
{
	return directory_exists(concat("exports/", setname));
}

// Check if room in room set exists
function utmt_room_exists(setname, roomname)
{
	if !utmt_roomset_exists(setname)
	{
		print("Room set ", setname, " doesn't exist")
		return false;
	}
	
	return file_exists(concat("exports/", setname, "/Rooms/", roomname, ".json"));
}

// Get room data from room set
function utmt_room_get(setname, roomname)
{
	if !utmt_room_exists(setname, roomname)
	{
		print("Room ", roomname, " in set ", setname, " doesn't exist")
		return undefined;
	}
	
	var roomFile = file_text_read_all(concat("exports/", setname, "/Rooms/", roomname, ".json"))
	var roomData = json_parse(roomFile)
	return roomData;
}

// Check if code from room set exists
function utmt_code_exists(setname, codename)
{
	if !utmt_roomset_exists(setname)
	{
		print("Room set ", setname, " doesn't exist")
		return false;
	}
	
	return file_exists(concat("exports/", setname, "/Code/", codename, ".gml"));
}

// Get code from room set
function utmt_code_get(setname, codename)
{
	if !utmt_code_exists(setname, codename)
	{
		print("Code ", codename, " in set ", setname, " doesn't exist")
		return "";
	}
	
	return file_text_read_all(concat("exports/", setname, "/Code/", codename, ".gml"));
}

// Go to specified room from current room set
function utmt_goto_room(roomname)
{
	if !utmt_room_exists(global.utmtRoomSet, roomname)
		exit;
	
	global.utmtRoom = utmt_room_get(global.utmtRoomSet, roomname)
	global.utmtRoomName = roomname
	
	room_set_width(rm_utmtroom, global.utmtRoom.width)
	room_set_height(rm_utmtroom, global.utmtRoom.height)
	
	room_goto(rm_utmtroom)
}

// Not really used right now
enum utmtValueType
{
	room,
	object,
	sprite,
}

// Update value in code if found
// Currently only used for changing the targetRoom variable
// so that it becomes a string
function utmt_update_value(code, variablename, valuetype = utmtValueType.room)
{
	var fullVarName = concat(variablename, " = ")
	var fullVarPos = 0
					
	var stringPos = string_pos(fullVarName, code)
	if (stringPos != 0)
	{
		fullVarPos = stringPos + string_length(fullVarName)
						
		var endPos = fullVarPos
		while (string_char_at(code, endPos) != ";")
			endPos++
						
		var varValue = string_copy(code, fullVarPos, endPos - fullVarPos)
		var newVarValue = ""
		switch valuetype
		{
			default:
				newVarValue = concat("\"", varValue, "\"")
				break
		}
		if (newVarValue != "")
			code = string_replace_all(code, varValue, newVarValue)
		
		print("Replaced value ", varValue, " with ", newVarValue)
	}
	
	return code;
}