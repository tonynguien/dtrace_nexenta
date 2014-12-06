#!/usr/sbin/dtrace -s

fbt:zfs:arc_kmem_reap_now:entry
{
    self->start[probefunc] = timestamp;
    self->strategy = args[0];
    self->in_kmem = 1;
}

fbt::arc_adjust:entry,
fbt::arc_shrink:entry,
fbt::arc_do_user_evicts:entry,
fbt::dnlc_reduce_cache:entry,
fbt::kmem_cache_reap_now:entry
/self->in_kmem/
{
    self->start[probefunc] = timestamp;
}

fbt::arc_adjust:return,
fbt::arc_shrink:return,
fbt::arc_do_user_evicts:return,
fbt::dnlc_reduce_cache:return,
fbt::kmem_cache_reap_now:entry
/self->start[probefunc] && self->in_kmem/
{
        printf("%Y %d ms", walltimestamp,
                (timestamp - self->start[probefunc]) / 1000000);
        self->start[probefunc] = NULL;
}

fbt::arc_kmem_reap_now:return
/self->start[probefunc]/
{
        printf("%Y %d ms, strategy %d", walltimestamp,
                (timestamp - self->start[probefunc]) / 1000000, self->strategy);
        self->start[probefunc] = NULL;
        self->in_kmem = NULL;
}
