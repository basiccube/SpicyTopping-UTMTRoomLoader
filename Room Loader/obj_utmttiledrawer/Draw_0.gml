// Everything here is done the way it is for performance reasons

var camX = camera_get_view_x(view_camera[0])
var camY = camera_get_view_y(view_camera[0])
var camW = camera_get_view_width(view_camera[0])
var camH = camera_get_view_height(view_camera[0])

var xDrawStart = max(0, floor(camX / tileset.width))
var yDrawStart = max(0, floor(camY / tileset.height))
var xDrawEnd = min(tilemapWidth, ceil((camX + camW) / tileset.width))
var yDrawEnd = min(tilemapHeight, ceil((camY + camH) / tileset.height))

for (var i = xDrawStart; i < xDrawEnd; i++)
{
	for (var j = yDrawStart; j < yDrawEnd; j++)
	{
		var tile = ds_grid_get(tilemap, i, j)
		if (tile == undefined)
			continue;
		if (tile == 0)
			continue;
		
		var tileX = i * tileset.width
		var tileY = j * tileset.height
		
		var tilesetX = tileset.borderX + (tileset.width * tile) + ((tileset.borderX * 2) * tile)
		var tilesetY = tileset.borderY
		
		var tilesetPos = floor(tilesetX / tilesetWidth)
		tilesetX -= tilesetWidth * tilesetPos
		tilesetY += (tileset.height + (tileset.borderY * 2)) * tilesetPos
		
		draw_sprite_part(tileset.sprite, 0, tilesetX, tilesetY, tileset.width, tileset.height, tileX, tileY)
	}
}