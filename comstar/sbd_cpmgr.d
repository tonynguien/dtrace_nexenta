#!/usr/sbin/dtrace -s

/*
typedef struct cm_target_desc {
        stmf_lu_t       *td_lu;
        uint32_t        td_disk_block_len;
        uint8_t         td_lbasize_shift;
} cm_target_desc_t;

*
* Current implementation supports 2 target descriptors (identification type)
* for src and dst and one segment descriptor (block -> block).
*

typedef struct cpmgr {
        cm_target_desc_t        cm_tds[CPMGR_MAX_TARGET_DESCRIPTORS];
        uint8_t                 cm_td_count;
        uint16_t                cm_src_td_ndx;
        uint16_t                cm_dst_td_ndx;
        cm_state_t              cm_state;
        uint32_t                cm_status;
        uint64_t                cm_src_offset;
        uint64_t                cm_dst_offset;
        uint64_t                cm_copy_size;
        uint64_t                cm_size_done;
        void                    *cm_xfer_buf;
        scsi_task_t             *cm_task;
} cpmgr_t;

*/

fbt:stmf_sbd:cpmgr_run:entry
{
	this->cpmgr = (cpmgr_t *) arg0;
	@copysz[ (uint64_t) this->cpmgr->cm_copy_size ] = count();
}

profile:::tick-1sec
{
	printa(@copysz); clear(@copysz);
}
