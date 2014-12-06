#!/usr/sbin/dtrace -qs

fbt:zfs:arc_release:entry
{
	self->tr = 1;
	self->buf = (arc_buf_t *) arg0;
	self->hdr = (arc_buf_hdr_t *) self->buf->b_hdr;
	self->l2hdr = (l2arc_buf_hdr_t *) self->hdr->b_l2hdr;
}

fbt::list_remove:entry
/self->tr/
{
	printf("%s buf_hdr:%p l2hdr:%p hdr_arg:%p\n",
	    probefunc, self->hdr, self->l2hdr, arg1);
}

fbt:zfs:arc_release:return
/self->tr/
{
	self->tr = 0;
}
