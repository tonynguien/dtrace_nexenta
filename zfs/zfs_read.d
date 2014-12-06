#!/usr/sbin/dtrace -s

/* I/O sync flags, see file.h */
inline int FSYNC = 16;
inline int FDSYNC = 64;

/*
fbt::zfs_seek:entry
{
	stack();
	@[probefunc] = count();
}

fbt:zfs:dmu_read_uio:entry
{
}
*/

fbt:zfs:zfs_read:entry
{
	this->uio = (uio_t *) arg1;
	this->uio_offset = (lloff_t) (this->uio->_uio_offset);

	this->vnode = (vnode_t *) arg0;
	this->znode = (znode_t *) this->vnode->v_data;

	printf("%s uio_offset: %d uio_resid: %d",
	    cleanpath(this->vnode->v_path), this->uio_offset._f, this->uio->uio_resid);
}

/*
fbt:zfs:zfs_write:entry
{
	@[probefunc] = count();
}*/

profile:::tick-5s
{
	printf("\n==============================================\n");
	/*printf("\nSummary"); printa(@); */
}
