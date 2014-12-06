#!/usr/sbin/dtrace -s

/*
* zfs read/sync|async write/sync event tracing.
* 
*/


/*
 * I/O sync flags, see file.h
 */
inline int FSYNC = 16;
inline int FDSYNC = 64;

fbt::zfs_read:entry
{
	self->read_ts = timestamp;
	@[probefunc] = count();
	@["Total"] = count();
}

fbt:zfs:zfs_sync:entry
{
	self->sync_ts = timestamp;
	@[probefunc] = count();
	@["Total"] = count();
}

/*
 * Determine sync write using below logic(see zfs_write):
 *
 *   if (ioflag & (FSYNC | FDSYNC) ||
 *      (zfsvfs->z_os->os_sync == ZFS_SYNC_ALWAYS))
 */
fbt:zfs:zfs_write:entry
/arg2 & (FSYNC | FDSYNC)/ /* need to handle zfsvfs->z_os->os_sync == ZFS_SYNC_ALWAYS */
{
	/* printf("os_sync: %d", arg0->v_data->z_zfsvfs->z_os->os_sync); */
	self->sync_write_ts = timestamp;
	@["zfs_sync_write"] = count();
	@["Total"] = count();
}

fbt:zfs:zfs_write:entry
/(arg2 & (0x10 | 0x40)) == 0/
{
	self->write_ts = timestamp;
	@["zfs_write"] = count();
	@["Total"] = count();
}

fbt::zfs_read:return
/self->read_ts/
{
	@read = quantize(timestamp - self->read_ts);
	self->read_ts = 0;
}

fbt::zfs_sync:return
/self->sync_ts/
{
	@sync = quantize((timestamp - self->sync_ts)/1000);
	self->sync_ts = 0;
}

fbt::zfs_write:return
/self->write_ts/
{
	@write = quantize((timestamp - self->write_ts)/1000);
	self->write_ts = 0;
}

fbt::zfs_write:return
/self->sync_write_ts/
{
	@sync_write = quantize((timestamp - self->write_ts)/1000);
	self->sync_write_ts = 0;
}

profile:::tick-5s
{
	printf("\n==============================================\n");
	printf("\tRead latency(usec)"); printa(@read);
	printf("\tSync latency(usec)"); printa(@sync);
	printf("\tWrite latency(usec)"); printa(@write);
	printf("\tSync write(usec)"); printa(@sync_write);

	printf("\nSummary"); printa(@);
}
