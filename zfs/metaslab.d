#!/usr/sbin/dtrace -s

fbt:zfs:metaslab_alloc:entry
{
self->ts = timestamp;
        @bs = quantize(arg2);
}

fbt:zfs:metaslab_alloc:return
/self->ts/
{
        @ = quantize((timestamp - self->ts) / 1000);
	self->ts = 0;
}

profile:::tick-10s
{
        printf("\nLatencies");
        printa(@);
        printf("\nslab size");
        printa(@bs);
}
