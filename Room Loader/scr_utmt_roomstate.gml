// Instance manager and map for storing layer tilemap IDs
// I feel like the instance manager could be removed or changed
// but it works
// The instance manager was copied from CYOP code in the mod

global.utmtInstanceManager = ds_map_create()
global.utmtLayerTilemaps = ds_map_create()
global.utmtSecretID = -4

// Reset states of UTMT rooms
// Also resets regular room states
function utmt_roomstate_reset()
{
	trace("UTMT room states reset")
	ds_map_clear(global.utmtInstanceManager)
	ds_map_clear(global.utmtLayerTilemaps)
	
	ds_list_clear(global.saveroom)
	ds_list_clear(global.baddieroom)
	ds_list_clear(global.escaperoom)
}

// Update instance manager
// Copied from CYOP code
function utmt_instance_update(_instance_id, _instance)
{
	if ds_map_exists(global.utmtInstanceManager, _instance_id)
	{
		var inst = ds_map_find_value(global.utmtInstanceManager, _instance_id)
		
		var listind = ds_list_find_index(global.saveroom, inst)
		if (listind != -1)
			ds_list_replace(global.saveroom, listind, _instance)
			
		listind = ds_list_find_index(global.baddieroom, inst)
		if (listind != -1)
			ds_list_replace(global.baddieroom, listind, _instance)
			
		listind = ds_list_find_index(global.escaperoom, inst)
		if (listind != -1)
			ds_list_replace(global.escaperoom, listind, _instance)
	}
	
	ds_map_replace(global.utmtInstanceManager, _instance_id, _instance)
}