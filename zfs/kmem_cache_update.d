#!/usr/sbin/dtrace -qs

kmem_cache_update:entry
/args[0]->cache_name=="zio_data_buf_131072" || args[0]->cache_name=="zio_data_buf_8192" || args[0]->cache_name=="zio_data_buf_65536" || args[0]->cache_name=="zio_data_buf_32768" || args[0]->cache_name=="zio_data_buf_4096" || args[0]->cache_name=="arc_buf_hdr_t" || args[0]->cache_name=="zio_data_buf_16384"/
{
	cp = args[0];
	full = args[0]->cache_full;
	empty = args[0]->cache_empty;

	printf("%Y\n", walltimestamp);
	printf("%s buftotal:%d bufslab:%d bufsize:%d slabsize:%d complete_slab:%d\n",
	    cp->cache_name, cp->cache_buftotal, cp->cache_bufslab, cp->cache_bufsize,
	    cp->cache_slabsize, cp->cache_complete_slab_count);
	printf("%s full_mags_total:%d full_mags_min:%d full_mags_reaplimit:%d\n",
	    cp->cache_name, full.ml_total, full.ml_min, full.ml_reaplimit);
	printf("%s empty_mags_total:%d empty_mags_min:%d empty_mags_reaplimit:%d\n\n",
	    cp->cache_name, empty.ml_total, empty.ml_min, empty.ml_reaplimit);
}
