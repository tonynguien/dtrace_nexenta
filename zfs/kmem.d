#!/usr/sbin/dtrace -qs

fbt::arc_kmem_reap_now:entry,
fbt::kmem_reap:entry,
fbt::kmem_depot_ws_reap:entry
{
	@[probefunc] = count();
	/* printf("\n%s", probefunc); stack(); printf("\n"); */
}

fbt::arc_kmem_reap_now:entry
{ self->reap_ts = timestamp; self->strat = args[0]; }

fbt::arc_kmem_reap_now:return
/self->reap_ts/
{
	printf("%s strategy:%d  duration:%d (usecs)\n", probefunc,
	    self->strat, (timestamp - self->reap_ts)/1000);
	@reaps[probefunc, self->strat, (timestamp - self->reap_ts)/1000] = count();

	self->reap_ts = 0; self->strat = 0;
}

fbt::kmem_depot_ws_reap:entry
{
	self->ts = timestamp;
	self->cache = args[0];
	self->buftotal_b4 = args[0]->cache_buftotal;
}

fbt::kmem_depot_ws_reap:return
/self->ts/
{
	@s[walltimestamp, stringof(self->cache->cache_name), self->buftotal_b4,
	    self->cache->cache_buftotal, (timestamp - self->ts)/1000] = count();

	printf("%Y cache:%s buftotal_b4:%d  buftotal_after:%d duration:%d (usecs)\n",
	    walltimestamp, stringof(self->cache->cache_name), self->buftotal_b4,
	    self->cache->cache_buftotal, (timestamp - self->ts)/1000);

	self->ts = 0;
	self->cache = 0;
	self->buftotal_b4 = 0;
	self->nm = 0;
}

dtrace:::END
{
	printa(@);

	printf("time cache buftotal_b4  buftotal_after duration (usecs) count\n");
	printa("%Y %s %d %d %d %@10d\n", @s);

}
