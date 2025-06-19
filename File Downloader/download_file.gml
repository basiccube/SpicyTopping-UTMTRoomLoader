// Download a file.
function download_file(url, dest, finishfunc = -4)
{
	var inst = instance_create(0, 0, obj_filedownloader)
	inst.fileurl = url
	inst.filedest = dest
	inst.finishfunc = finishfunc
	
	return inst;
}