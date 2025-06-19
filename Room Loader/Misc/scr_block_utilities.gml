// The functions that PT uses for deleting tiles.
// I only kept the things that are important for the UTMT room loader functionality here.

function scr_destroy_tiles(tile_size, layer_id, offset = 0)
{
	var foundTileDrawer = false
	var tileDrawerID = -4
	with (obj_utmttiledrawer)
	{
		var name = layer_id
		if !is_string(name)
			name = layer_get_name(layer_id)
		
		if (layerName == name)
		{
			tileDrawerID = id
			foundTileDrawer = true
		}
	}
	
	var lay_id = layer_get_id(layer_id)
	if (lay_id != -1 || foundTileDrawer)
	{
		var map_id = layer_tilemap_get_id(lay_id)
		if (room == rm_utmtroom)
			map_id = ds_map_find_value(global.utmtLayerTilemaps, layer_id)
		
		if ((map_id == -1 || is_undefined(map_id)) && !foundTileDrawer)
			exit;
		
		var w = abs(sprite_width) / tile_size
		var h = abs(sprite_height) / tile_size
		var ix = sign(image_xscale)
		var iy = sign(image_yscale)
		if (ix < 0)
			w++
		
		for (var yy = (0 - offset); yy < (h + offset); yy++)
		{
			for (var xx = (0 - offset); xx < (w + offset); xx++)
			{
				var tileX = x + ((xx * tile_size) * ix)
				var tileY = y + ((yy * tile_size) * iy)
				if foundTileDrawer
					scr_destroy_utmttile(tileX, tileY, tileDrawerID)
				else
					scr_destroy_tile(tileX, tileY, map_id)
			}
		}
	}
}

function scr_destroy_tile_arr(tile_size, layer_arr, offset = 0)
{
    for (var i = 0; i < array_length(layer_arr); i++)
        scr_destroy_tiles(tile_size, layer_arr[i], offset)
}

function scr_destroy_tile(tile_x, tile_y, tilemap_element_id)
{
	var data = tilemap_get_at_pixel(tilemap_element_id, tile_x, tile_y)
	data = tile_set_empty(data)
	
	tilemap_set_at_pixel(tilemap_element_id, data, tile_x, tile_y)
}

function scr_destroy_utmttile(tile_x, tile_y, tiledrawer_id)
{
	with (tiledrawer_id)
	{
		var gridX = floor(tile_x / tileset.width)
		var gridY = floor(tile_y / tileset.height)
		ds_grid_set(tilemap, gridX, gridY, 0)
	}
}