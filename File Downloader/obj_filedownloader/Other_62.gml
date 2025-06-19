if (ds_map_find_value(async_load, "id") == fileid)
{
	var status = ds_map_find_value(async_load, "status")
	if (status < 0)
	{
		error("Error downloading file ", fileurl)
		instance_destroy()
	}
	else if (status == 0)
	{
		info("Finished downloading file ", fileurl)
		if (finishfunc != -4)
			finishfunc()
		instance_destroy()
	}
	else
	{
		var prevprogress = progress
		progress = ds_map_find_value(async_load, "sizeDownloaded")
		size = ds_map_find_value(async_load, "contentLength")
		
		if (prevprogress != progress)
			trace("[", (progress / size) * 100, "%] ", progress, "/", size, " downloaded (", filedest, ")")
	}
}