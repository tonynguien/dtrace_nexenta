#!/usr/sbin/dtrace -ws

#pragma D option quiet

arc_kmem_reap_now:entry
{
	self->ts[probefunc] = timestamp;
	chill(500000000);
}

arc_kmem_reap_now:return
{
	printf("  %Y  spent %ums in %s\n\n", walltimestamp,
	    (timestamp - self->ts[probefunc])/1000/1000, probefunc);
}
