#!/usr/sbin/dtrace -qs

/*
 * Code path we're interested in
 *
 * sbd_handle_read-> sbd_do_sgl_read_xfer -> sbd_zvol_alloc_read_bufs(sl, dbuf)
 * sbd_handle_write-> sbd_do_sgl_write_xfer -> sbd_zvol_alloc_write_bufs(sl, dbuf)

dtrace:::BEGIN
{
	printf("Thread LUN task probename z_id offset len type (r_cnt) (wr_wanted) (read_wanted)\n");
}
 */

fbt::sbd_handle_read:entry
{
	self->tr = 1;
}

fbt:stmf_sbd:sbd_do_sgl_read_xfer:entry
/self->tr/
{
	self->task = (scsi_task_t *) arg0;
	@[probefunc] = count();

	/*
	printf("%d thread:%p task:%p xfer_len:%d nbytes_xferred:%d 1st_xfer:%d copy_threshold:%d\n",
	    timestamp, curthread, self->task,
	    self->task->task_cmd_xfer_length,	/ xfer len based on CDB /
	    self->task->task_nbytes_transferred,
	    self->task->task_1st_xfer_len,	/ 1st xfer hint /
	    self->task->task_copy_threshold);
	*/
}

fbt:stmf_sbd:sbd_zvol_alloc_read_bufs:entry
/self->tr/
{
	@[probefunc] = count();
	self->sl = (sbd_lu_t *) arg0;
	this->dbuf = (stmf_data_buf_t *) arg1;
	this->zvio = (sbd_zvol_io_t *) this->dbuf->db_lu_private;

	printf("RD: %d %p %s %p offset:%-15d size:%-6d sglen:%d\n",
	    timestamp, curthread, stringof(self->sl->sl_name), self->task,
	    this->zvio->zvio_offset, this->dbuf->db_data_size,
	    this->dbuf->db_sglist_length);
}

fbt::sbd_handle_write:entry
{
	self->tr = 1;
}

fbt:stmf_sbd:sbd_do_sgl_write_xfer:entry
/self->tr/
{
	self->task = (scsi_task_t *) arg0;
	@[probefunc] = count();
}

fbt:stmf_sbd:sbd_zvol_alloc_write_bufs:entry
/self->tr/
{
	@[probefunc] = count();
	this->sl = (sbd_lu_t *) arg0;
	this->dbuf = (stmf_data_buf_t *) arg1;
	this->zvio = (sbd_zvol_io_t *) this->dbuf->db_lu_private;
	printf("WR: %d %p %s %p offset:%-15d size:%-6d\n",
	    timestamp, curthread, stringof(this->sl->sl_name), self->task,
	    this->zvio->zvio_offset, this->dbuf->db_data_size);
}

fbt::qlt_dma_setup_dbuf:entry
/self->tr/
{
	@[probefunc] = count();
}

/*
fbt:zfs:zfs_range_lock:entry
/self->tr/
{
	this->zp = (znode_t *) arg0;
	printf("%d %p %s %p %s %d %d %d %d\n",
	    timestamp, curthread, stringof(self->sl->sl_name), self->task, probefunc,
	    this->zp->z_id, arg1, arg2, arg3);
}

fbt:zfs:zfs_range_unlock:entry
/self->tr/
{
	this->rl = (rl_t *) arg0;
	this->zp  = (znode_t *) this->rl->r_zp;
	printf("%d %p %s %p %s %d %d %d %d %d %d %d\n",
	    timestamp, curthread, stringof(self->sl->sl_name), self->task, probefunc,
	    this->zp->z_id, this->rl->r_off, this->rl->r_len, this->rl->r_type,
	    this->rl->r_cnt, this->rl->r_write_wanted, this->rl->r_read_wanted);
} */

fbt::sbd_handle_read:return
/self->tr/ { self->tr = 0; }

fbt::sbd_handle_write:return
/self->tr/ { self->tr = 0; }
