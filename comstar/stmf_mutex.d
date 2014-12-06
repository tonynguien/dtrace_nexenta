#!/usr/sbin/dtrace -s

#pragma dynvarsize=16M
#pragma bufpolicy=ring

/* 
 * Tracing mutexes used by stmf
 * we know that the code in question is called from sbd_new_task()
 * the mutex may still be held when we exit sbd_new_task(), or it
 * a mutex can be recursively acquired inside sbd_new_task()
 * we assume that dbuf mutexes are acquired and released in a proper
 * nested fashion, but we will find out
 */

fbt:stmf_sbd:sbd_new_task:entry
{
	self->total = 0;
	self->trace = 1;
	self->spec[self->total] = 0;
}

fbt:stmf_sbd:sbd_new_task:return
/self->trace && self->total && self->spec[self->total]/
{
	commit(self->spec[self->total]);
	self->total--;
	self->spec[self->total] = 0;
	self->trace = 0;
	/*
	 * we assume that we do not have multiple mutexes leaked, 
	 * but we will see
	 */
}

fbt:stmf_sbd:sbd_new_task:return
/self->trace && (self->total == 0)/
{
	self->trace = 0;
}

/* Gather dbuf mutexes for further filtering */
fbt:zfs:dbuf_find:return,
fbt:zfs:dbuf_hash_insert:return
/self->trace/
{
	self->spec[self->total] = speculation();
	speculate(self->spec[self->total]);
	this->db = (dmu_buf_impl_t*)arg1;
	this->mtx=(uint64_t)&this->db->db_mtx;
	/* these functions take the mutex */
	self->filter[this->mtx] = 1;
	self->a[arg0] = 1;
	self->total++;
	/* record mutex and stack */
	printf("Mutex %p acquired, stack follows:\n", this->mtx);
	stack();
}

lockstat:genunix:mutex_enter:adaptive-acquire
/self->trace && self->filter[arg0] && (self->a[arg0] == 0)/
{
	self->spec[self->total] = speculation();
	speculate(self->spec[self->total]);
	self->a[arg0] = 1;
	self->total++;
	/* record mutex and stack */
	printf("Mutex %p acquired, stack follows:\n", arg0);
	stack();
}

/*
 * the lockstat:::adaptive-aquire probes fire after a mutex has been
 * acquired; in the case of recursive mutex, this will not happen - 
 * we will get a panic, so we need to catch this at fbt entry point
 */
fbt:unix:mutex_vector_enter:entry
/self->trace && self->filter[arg0] && (self->a[arg0] != 0)/
{
	/* 
	 * we rely here on dbuf mutexes being acquired and released 
	 * in proper nested fashion, which seems a good assumption
	 * but we will see
	 */
	self->total--;
	commit(self->spec[self->total]);
	self->spec[self->total] = 0;
	/* at this point, it will panic, so not further action needed */
}

lockstat:genunix:mutex_exit:adaptive-release
/self->trace && self->filter[arg0] && (self->a[arg0] == 1)/
{
	self->a[arg0] = 0;
	self->total--;
	/* 
	 * we rely here on dbuf mutexes being acquired and released 
	 * in proper nested fashion, which seems a good assumption
	 * but we will see
	 */
	discard(self->spec[self->total]);
	self->spec[self->total] = 0;
}

lockstat:genunix:mutex_exit:adaptive-release
/self->trace && self->filter[arg0] && (self->a[arg0] != 1)/
{
	self->total--;
	/* 
	 * we rely here on dbuf mutexes being acquired and released 
	 * in proper nested fashion, which seems a good assumption
	 * but we will see
	 */
	commit(self->spec[self->total]);
	self->spec[self->total] = 0;
}

