#!/usr/sbin/dtrace -qs

fbt::sbd_import_lu:entry
{
	@[probefunc] = count();
}

fbt::sbd_proxy_reg_lu:entry
{
	@[probefunc] = count();
}

fbt::sbd_remove_it_handle:entry
{
	this->lu = (sbd_lu_t *) arg0;
	printf("sbd_remove_it_handle: %s\n", stringof(this->lu->sl_name));

	@[probefunc] = count();
	@s[stringof(this->lu->sl_name), stack()] = count();
	@handles[stringof(this->lu->sl_name)] = count();
}
