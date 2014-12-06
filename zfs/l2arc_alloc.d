#!/usr/sbin/dtrace -s

l2arc_write_buffers:entry
{
	self->tr = 1;
}

kmem_cache_alloc:entry
/self->tr/
{
	@[args[0]->cache_name, stack()]=count();
}

l2arc_write_buffers:return
/self->tr/ { self->tr = 0; }

profile:::tick-5sec { printa(@); trunc(@); }
