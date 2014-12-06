#!/usr/sbin/dtrace -Fs

#pragma D option flowindent

fbt:stmf:stmf_lun_reset_poll:entry
{
	self->ts=timestamp;
	this->lu =  (stmf_lu_t *) arg0;
	this->ilu =  (stmf_i_lu_t *) this->lu->lu_stmf_private;

	this->ntasks_pending = this->ilu->ilu_ntasks - this->ilu->ilu_ntasks_free;
	printf("\nstmf_lu_t:%x    ntasks_pending:%d\n", arg0, this->ntasks_pending);
}

fbt:stmf::entry
/self->ts/
{}

fbt:stmf::return
/self->ts/
{}


fbt:stmf:stmf_lun_reset_poll:return
/self->ts/
{
	self->ts=0;
}


