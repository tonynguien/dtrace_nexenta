#!/usr/sbin/dtrace -qs

fbt:zfs:spa_import:entry
{ self->tr = 1;}

fbt:zfs::entry
/self->tr && probefunc != "spa_import"/ { self->probefunc = timestamp;}

fbt:zfs::return
/self->tr && self->probefunc/
{
        self->probefunc_lat = timestamp - self->probefunc;
        self->probefunc = 0;
        stack();
        printf("%s elapsed: %d (usecs)\n", probefunc, self->probefunc_lat/1000);
}

fbt:zfs:spa_import:return
/self->tr/ { self->tr = 0;}
