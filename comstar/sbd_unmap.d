#!/usr/sbin/dtrace -qs

fbt::sbd_unmap:entry
{
        self->tr = 1;
        self->unmap = timestamp;
	printf("%Y\n", walltimestamp);
        stack();
}

fbt::dbuf_free_range:entry
/self->tr/
{
        self->dbuf = timestamp;
}

fbt::dbuf_free_range:return
/self->tr/
{
        @[probefunc] = quantize(timestamp - self->dbuf);
        printa(@);
}

fbt::sbd_unmap:return
/self->tr/
{
        printf("%s takes: %d us", probefunc, (timestamp - self->unmap)/1000);
        printa(@); trunc(@); self->tr = 0;
}
