// Look through all of the layers in the room data
// and make, well, room layers out of that data.

for (var i = 0; i < array_length(global.utmtRoom.layers); i++)
{
	// Some basic info that will be used
	var layData = global.utmtRoom.layers[i]
	var type = layData.layer_type
	var name = layData.layer_name
	
	// Set up and create the layer
	print("Setting up layer ", name)
	var lay = layer_create(layData.layer_depth, name)
	
	layer_x(lay, layData.x_offset)
	layer_y(lay, layData.y_offset)
	layer_hspeed(lay, layData.h_speed)
	layer_vspeed(lay, layData.v_speed)
	layer_set_visible(lay, layData.is_visible)
	
	// Determine what the layer is for using the type
	switch type
	{
		// Background layer
		case 1:
			print("Found background layer ", name)
			
			var bgData = layData.layer_data
			if (bgData.sprite == pointer_null)
			{
				print("Background sprite is null")
				break
			}
			
			// Try to get the sprite of the background
			// If it isn't found, then try looking if it was exported and use that instead
			var bgSprite = asset_get_index(bgData.sprite)
			if (bgSprite == -1 || asset_get_type(bgData.sprite) != asset_sprite)
			{
				var spritePath = concat("exports/", global.utmtRoomSet, "/Sprites/", bgData.sprite, ".gif")
				if (global.utmtHasSprites && file_exists(spritePath))
				{
					if !ds_map_exists(global.utmtSprites, bgData.sprite)
						ds_map_replace(global.utmtSprites, bgData.sprite, utmt_add_sprite(bgData.sprite))
					
					bgSprite = ds_map_find_value(global.utmtSprites, bgData.sprite)
				}
				else
				{
					warn("Background sprite doesn't exist: ", bgData.sprite)
					break
				}
			}
			
			// Create background layer
			var bg = layer_background_create(lay, bgSprite)
			layer_background_visible(bg, bgData.visible)
			layer_background_blend(bg, bgData.color)
			
			layer_background_index(bg, bgData.first_frame)
			layer_background_speed(bg, bgData.animation_speed)
			
			layer_background_htiled(bg, bgData.tiled_horizontally)
			layer_background_vtiled(bg, bgData.tiled_vertically)
			layer_background_stretch(bg, bgData.stretch)
			break
		
		// Instance layer
		case 2:
			print("Found instance layer ", name)
			
			var instData = layData.layer_data.instances
			for (var j = 0; j < array_length(instData); j++)
			{
				var objectData = instData[j]
				var objectName = objectData.object_definition
				var instanceID = concat(global.utmtRoomName, "_", j)
				
				// Check the object map and see if the object needs to be renamed
				var objectMapNames = variable_struct_get_names(global.utmtObjectMap)
				for (var k = 0; k < array_length(objectMapNames); k++)
				{
					if (objectName == objectMapNames[k])
					{
						objectName = variable_struct_get(global.utmtObjectMap, objectName)
						break
					}
				}
				
				if (objectName == pointer_null)
				{
					print("Object is null")
					continue;
				}
				
				var object = asset_get_index(objectName)
				if (object == -1 || asset_get_type(objectName) != asset_object)
				{
					warn("Object doesn't exist: ", objectName)
					continue;
				}
				
				// Create instance of object
				var inst = instance_create_depth(objectData.x, objectData.y, 0, object,
				{
					image_xscale : objectData.scale_x,
					image_yscale : objectData.scale_y,
					image_angle : objectData.rotation,
					
					image_blend : objectData.color,
					image_index : objectData.image_index,
					image_speed : objectData.image_speed,
				})
				
				// Check if pre-creation code isn't null,
				// update whatever values need to be updated
				// and then use GMLive to execute it
				if (objectData.pre_create_code != pointer_null)
				{
					var code = utmt_code_get(global.utmtRoomSet, objectData.pre_create_code)
					code = utmt_update_value(code, "targetRoom")
					
					with (inst)
					{
						var result = live_execute_string(code)
						if !result
							error("Pre creation code error: ", live_result)
					}
				}
				
				// If room set was detected to require old build fixes,
				// apply the ones for objects here
				if global.utmtUseOldFixes
				{
					if (inst.object_index == obj_ladder)
						inst.visible = true
					if (inst.object_index == obj_minijohn)
						inst.escape = true
				}
				
				// Check if creation code isn't null,
				// update whatever values need to be updated
				// and then use GMLive to execute it
				if (objectData.creation_code != pointer_null)
				{
					var code = utmt_code_get(global.utmtRoomSet, objectData.creation_code)
					code = utmt_update_value(code, "targetRoom")
					
					with (inst)
					{
						var result = live_execute_string(code)
						if !result
							error("Creation code error: ", live_result)
					}
				}
				
				// Update the instance manager
				utmt_instance_update(instanceID, inst)
			}
			break
		
		// Asset layer
		case 3:
			print("Found asset layer ", name)
			
			var assetData = layData.layer_data
			for (var j = array_length(assetData.sprites) - 1; j >= 0; j--)
			{
				var sprData = assetData.sprites[j]
				if (sprData.sprite == pointer_null)
				{
					print("Sprite is null")
					continue;
				}
				
				// Try to get the sprite of the asset
				// If it isn't found, then try looking if it was exported and use that instead
				var sprIndex = asset_get_index(sprData.sprite)
				if (sprIndex == -1 || asset_get_type(sprData.sprite) != asset_sprite)
				{
					var spritePath = concat("exports/", global.utmtRoomSet, "/Sprites/", sprData.sprite, ".gif")
					if (global.utmtHasSprites && file_exists(spritePath))
					{
						if !ds_map_exists(global.utmtSprites, sprData.sprite)
							ds_map_replace(global.utmtSprites, sprData.sprite, utmt_add_sprite(sprData.sprite))
					
						sprIndex = ds_map_find_value(global.utmtSprites, sprData.sprite)
					}
					else
					{
						warn("Sprite doesn't exist: ", sprData.sprite)
						continue;
					}
				}
				
				// Create sprite on asset layer
				var spr = layer_sprite_create(lay, sprData.x, sprData.y, sprIndex)
				layer_sprite_xscale(spr, sprData.scale_x)
				layer_sprite_yscale(spr, sprData.scale_y)
				layer_sprite_angle(spr, sprData.rotation)
				layer_sprite_blend(spr, sprData.color)
				
				layer_sprite_index(spr, sprData.frame_index)
				layer_sprite_speed(spr, sprData.animation_speed)
			}
			break
		
		// Tile layer
		case 4:
			print("Found tile layer ", name)
			
			var tilemapData = layData.layer_data
			var tileData = tilemapData.tile_data
			var tilesetName = tilemapData.background
			
			// Check the tileset map if the tileset needs to be renamed
			var tilesetMapNames = variable_struct_get_names(global.utmtTilesetMap)
			for (var j = 0; j < array_length(tilesetMapNames); j++)
			{
				if (tilesetName == tilesetMapNames[j])
				{
					tilesetName = variable_struct_get(global.utmtTilesetMap, tilesetName)
					break
				}
			}
			
			// If old build fixes are required,
			// Check if the tileset needs to be renamed possibly again
			if global.utmtUseOldFixes
			{
				var oldTilesetMapNames = variable_struct_get_names(global.utmtOldTilesetMap)
				for (var j = 0; j < array_length(oldTilesetMapNames); j++)
				{
					if (tilesetName == oldTilesetMapNames[j])
					{
						tilesetName = variable_struct_get(global.utmtOldTilesetMap, tilesetName)
						break
					}
				}
			}
			
			if (tilesetName == pointer_null)
			{
				print("Tileset is null")
				break
			}
			
			// Try to get the tileset
			// If it isn't found, then try looking if it was exported
			// and then use the tile drawer instead of the regular tilemap
			var tileset = asset_get_index(tilesetName)
			var useTileDrawer = false
			if (tileset == -1 || asset_get_type(tilesetName) != asset_tiles)
			{
				var tilesetPath = concat("exports/", global.utmtRoomSet, "/Tilesets/", tilesetName, ".png")
				if (global.utmtHasSprites && file_exists(tilesetPath))
				{
					if !ds_map_exists(global.utmtTilesets, tilesetName)
						ds_map_replace(global.utmtTilesets, tilesetName, utmt_add_tileset(tilesetName))
					
					tileset = ds_map_find_value(global.utmtTilesets, tilesetName)
					useTileDrawer = true
				}
				else
				{
					warn("Tileset doesn't exist: ", tilesetName)
					break
				}
			}
			
			// Use tile drawer if using exported tileset
			if useTileDrawer
			{
				print("Using tile drawer for ", name)
				
				var tileDrawer = instance_create_layer(0, 0, lay, obj_utmttiledrawer)
				tileDrawer.tileset = tileset
				tileDrawer.tilemap = ds_grid_create(tilemapData.tiles_x, tilemapData.tiles_y)
				tileDrawer.layerName = name
				
				// Assign tilemap grid cells with their respective tile IDs
				for (var j = 0; j < array_length(tileData); j++)
				{
					var tileStrip = tileData[j]
					for (var k = 0; k < array_length(tileStrip); k++)
					{
						var tile = tileStrip[k].id
						ds_grid_set(tileDrawer.tilemap, k, j, tile)
					}
				}
				
				tileDrawer.tilesetWidth = sprite_get_width(tileset.sprite)
				tileDrawer.tilemapWidth = ds_grid_width(tileDrawer.tilemap)
				tileDrawer.tilemapHeight = ds_grid_height(tileDrawer.tilemap)
			}
			else
			{
				// Create tilemap on the layer and add the layer tilemap ID to the map for later use
				var tilemap = layer_tilemap_create(lay, 0, 0, tileset, tilemapData.tiles_x, tilemapData.tiles_y)
				ds_map_replace(global.utmtLayerTilemaps, name, tilemap)
				
				for (var j = 0; j < array_length(tileData); j++)
				{
					var tileStrip = tileData[j]
					for (var k = 0; k < array_length(tileStrip); k++)
					{
						var tile = tileStrip[k].id
						tilemap_set(tilemap, tile, k, j)
					}
				}
			}
			break
		
		// Unknown/not implemented layer
		default:
			warn("Unknown layer type ", type, ", layer name: ", name)
			break
	}
}