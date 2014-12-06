#!/usr/sbin/dtrace -s

#pragma D option flowindent

/*
#define	SCMD_INQUIRY		0x12  18
#define	SCMD_READ_G1		0x28  40
#define	SCMD_WRITE_G1		0x2a  42
#define	SCMD_MAINTENANCE_IN	0xa3  163
*/

fbt::stmf_dlun0_new_task:entry,
fbt::sbd_new_task:entry
{
	this->task = (scsi_task_t *)arg0;
	this->dbuf = (stmf_data_buf_t *)arg1;
	self->time = timestamp;

	printf("[%d:%03d:%03d:%03d] task=%p",
	    timestamp / 1000000000 , (timestamp / 1000000) % 1000,
	    (timestamp / 1000) % 1000, timestamp % 1000, this->task);

	tracemem(this->task->task_cdb, 1);
}

fbt::vn_rdwr:entry
/self->time/
{
	self->rdwr = 1;

	printf("[%d:%03d:%03d:%03d]",
	    timestamp / 1000000000 , (timestamp / 1000000) % 1000,
	    (timestamp / 1000) % 1000, timestamp % 1000);
}

fbt::vn_rdwr:return
/self->time && self->rdwr/
{
	printf("[%d:%03d:%03d:%03d]",
	    timestamp / 1000000000 , (timestamp / 1000000) % 1000,
	    (timestamp / 1000) % 1000, timestamp % 1000);

	self->rdwr = 0;
}

fbt::stmf_dlun0_new_task:return,
fbt::sbd_new_task:return
/self->time/
{
	printf("[%d:%03d:%03d:%03d] %s+%x returned %x\n\n",
	    timestamp / 1000000000 , (timestamp / 1000000) % 1000,
	    (timestamp / 1000) % 1000, timestamp % 1000,
	    probefunc, arg0, arg1);
	self->time = 0;
}

