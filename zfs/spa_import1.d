#!/usr/sbin/dtrace -qs

fbt:zfs:spa_import:entry
{ self->tr = 1;}

fbt:zfs:vdev_uberblock_load:entry,
fbt:zfs:spa_load_verify:entry,
fbt:zfs:txg_wait_synced:entry
/self->tr/ { self->probefunc = timestamp;}

fbt:zfs:traverse_visitbp:entry
/self->tr/ { @[stack()] = count(); }

fbt:zfs:vdev_uberblock_load:return,
fbt:zfs:spa_load_verify:return,
fbt:zfs:txg_wait_synced:return
/self->tr && self->probefunc/
{
        self->probefunc_lat = timestamp - self->probefunc;
        self->probefunc = 0;
        stack();
        printf("%s elapsed: %d (usecs)\n", probefunc, self->probefunc_lat/1000);
}

fbt:zfs:spa_import:return
/self->tr/ { self->tr = 0;}

