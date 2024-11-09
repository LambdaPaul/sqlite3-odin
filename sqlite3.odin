package sqlite

when ODIN_OS == .Windows {
	foreign import sqlite "lib/sqlite3.lib"
} else when ODIN_OS == .Darwin {
	when ODIN_ARCH == .arm64 {
		foreign import sqlite "lib/libsqlite3_arm64.a"
	} else when ODIN_ARCH == .amd64 {
		foreign import sqlite "lib/libsqlite3_x64.a"
	}
} else {
	foreign import sqlite "system:sqlite3"
}

VERSION :: "3.47.0"
VERSION_NUMBER :: 3047000
SOURCE_ID :: "2024-10-21 16:30:22 03a9703e27c44437c39363d0baf82db4ebc94538a0f28411c85dda156f82636e"


@(default_calling_convention = "cdecl", link_prefix = "sqlite3_")
foreign sqlite {
	libversion :: proc() -> cstring ---
	sourceid :: proc() -> cstring ---
	libversion_number :: proc() -> i32 ---

	compileoption_used :: proc(option_name: cstring) -> (defined: b32) ---
	compileoption_get :: proc(n: i32) -> cstring ---

	threadsafe :: proc() -> (is_thread_safe: b32) ---

	close :: proc(db: ^sqlite3) -> Result ---
	close_v2 :: proc(db: ^sqlite3) -> Result ---

	/*
	db:			An open database
	sql:	 	SQL to be evaluated
	cb:			Callback function
	arg:	 	1st argument to callback
	err_msg:	Error msg written here
	*/
	exec :: proc(db: ^sqlite3, sql: cstring, cb: callback, arg: rawptr, err_msg: [^]cstring) -> Result ---


	initialize :: proc() -> Result ---
	shutdown :: proc() -> Result ---
	config :: proc(options: Config, #c_vararg _: ..any) -> Result ---
	db_config :: proc(db: ^sqlite3, op: i32, #c_vararg options: ..Db_Config) -> Result ---

	extended_result_codes :: proc(db: ^sqlite3, onoff: b32) -> Result ---

	last_insert_rowid :: proc(db: ^sqlite3) -> i64 ---
	set_last_insert_rowid :: proc(db: ^sqlite3, row_id: i64) ---

	changes :: proc(db: ^sqlite3) -> i32 ---
	changes64 :: proc(db: ^sqlite3) -> i64 ---

	total_changes :: proc(db: ^sqlite3) -> i32 ---
	total_changes64 :: proc(db: ^sqlite3) -> i64 ---

	interrupt :: proc(db: ^sqlite3) ---
	interrupted :: proc(db: ^sqlite3) -> (success: b32) ---

	complete :: proc(sql: cstring) -> (success: b32) ---
	// omit complete16 :: proc(rawptr sql) ---

	busy_handler :: proc(db: ^sqlite3, busy: proc(arg: rawptr, proc_event_call_count: i32) -> i32, arg: rawptr) -> Result ---
	busy_timeout :: proc(db: ^sqlite3, ms: i32) -> Result ---

	@(deprecated = "This is a legacy interface that is preserved for backwards compatibility. Use of this interface is not recommended.")
	get_table :: proc(db: ^sqlite3, /* An open database */
		sql: cstring, /* SQL to be evaluated */
		result: ^[^]cstring, /* Results of the query */
		row: ^i32, /* Number of result rows written here */
		column: ^i32, /* Number of result columns written here */
		err_msg: [^]cstring, /* Error msg written here */) -> Result ---
	@(deprecated = "This is a legacy interface that is preserved for backwards compatibility. Use of this interface is not recommended.")
	free_table :: proc(result: [^]cstring) ---

	// mprintf :: proc(cstring,...) --> cstring ---
	// vmprintf :: proc(cstring, va_list) --> cstring ---
	// snprintf :: proc(i32,cstring,cstring, #c_vararg args: ..any) --> cstring ---
	// vsnprintf :: proc(i32,cstring,cstring, libc.va_list) cstring ---

	malloc :: proc(_: int) -> rawptr ---
	malloc64 :: proc(_: u64) -> rawptr ---
	realloc :: proc(ptr: rawptr, _: int) -> rawptr ---
	realloc64 :: proc(ptr: rawptr, _: u64) -> rawptr ---
	free :: proc(ptr: rawptr) ---
	msize :: proc(ptr: rawptr) -> u64 ---
	memory_used :: proc() -> i64 ---
	memory_highwater :: proc(resetFlag: b32) -> i64 ---
	randomness :: proc(n: i32, buffer: rawptr) ---

	set_authorizer :: proc(db: ^sqlite3, auth: proc(user_data: rawptr, code: Auth_Action_Code, _: cstring, _: cstring, _: cstring, _: cstring) -> Auth_Return_Code, user_data: rawptr) -> Auth_Return_Code ---
	trace_v2 :: proc(db: ^sqlite3, mask: Trace_Event_Code, trace: proc(code: Trace_Event_Code, ctx_arg: rawptr, code_p: rawptr, code_x: rawptr) -> i32, ctx_arg: rawptr) ---
	progress_handler :: proc(db: ^sqlite3, ops: i32, progress: proc(arg: rawptr) -> Result, arg: rawptr) ---
	/*
	filename: 	Database filename (UTF-8)
	db: 		SQLite db handle 
	*/
	open :: proc(filename: cstring, db: ^^sqlite3) -> Result ---
	// omit open16 :: proc(filename: rawptr, db: ^^sqlite3) -> Result ---


	/*
	filename: 	Database filename (UTF-8)
	db: 		SQLite db handle
	flags: 		Flags
	vfs: 		Name of VFS module to use
	*/
	open_v2 :: proc(filename: cstring, db: ^^sqlite3, flags: Open_Flags, vfs: cstring) -> Result ---


	errcode :: proc(db: ^sqlite3) -> Result ---
	extended_errcode :: proc(db: ^sqlite3) -> Result ---
	errmsg :: proc(db: ^sqlite3) -> cstring ---
	// omit errmsg16 :: proc(db: ^sqlite3) -> rawptr ---
	errstr :: proc(db: ^sqlite3) -> cstring ---
	error_offset :: proc(db: ^sqlite3) -> i32 ---

	limit :: proc(db: ^sqlite3, id: Limit_Category, newVal: i32) -> i32 ---

	/*
	db:		Database handle
	sql:	SQL statement, UTF-8 encoded
	nByte:	Maximum length of `sql` in bytes.
	stmt:	OUT: Statement handle
	tail:	OUT: Pointer to unused portion of `sql`
	*/
	@(deprecated = "'prepare' is deprecated, use 'prepare_v2' instead")
	prepare :: proc(db: ^sqlite3, sql: cstring, nByte: i32, stmt: ^^stmt, tail: [^]cstring) -> Result ---

	/*
	db:		Database handle
	sql:	SQL statement, UTF-8 encoded
	nByte:	Maximum length of `sql` in bytes.
	stmt:	OUT: Statement handle
	tail:	OUT: Pointer to unused portion of `sql`
	*/
	prepare_v2 :: proc(db: ^sqlite3, sql: cstring, nByte: i32, stmt: ^^stmt, tail: ^cstring) -> Result ---

	/*
	db:			Database handle
	sql:		SQL statement, UTF-8 encoded
	nByte:		Maximum length of `sql` in bytes.
	prepFlags:	Zero or more Prepare_Flag
	stmt:		OUT: Statement handle
	tail:		OUT: Pointer to unused portion of `sql`
	*/
	prepare_v3 :: proc(db: ^sqlite3, sql: cstring, nByte: i32, prepFlags: Prepare_Flag, stmt: ^^stmt, tail: [^]cstring) -> Result ---

	// omit prepare16(_v(2|3))

	sql :: proc(s: ^stmt) -> cstring ---
	expanded_sql :: proc(s: ^stmt) -> cstring ---
	//normalized_sql :: proc(s: ^stmt) -> cstring ---

	stmt_readonly :: proc(s: ^stmt) -> (success: b32) ---

	/* The stmt_isexplain(S) interface returns 1 if the
	prepared statement S is an EXPLAIN statement, or 2 if the
	statement S is an EXPLAIN QUERY PLAN.
	The stmt_isexplain(S) interface returns 0 if S is
	an ordinary statement or a NULL pointer. */
	stmt_isexplain :: proc(s: ^stmt) -> i32 ---

	stmt_explain :: proc(s: ^stmt, eMode: i32) -> Result ---
	stmt_busy :: proc(s: ^stmt) -> (success: b32) ---

	bind_blob :: proc(s: ^stmt, idx: i32, data: rawptr, n: i32, xDel: proc(ptr: rawptr)) -> Result ---
	bind_blob64 :: proc(s: ^stmt, idx: i32, data: rawptr, u64, xDel: proc(ptr: rawptr)) -> Result ---
	bind_double :: proc(s: ^stmt, idx: i32, rValue: f64) -> Result ---
	bind_int :: proc(s: ^stmt, idx: i32, iValue: i32) -> Result ---
	bind_int64 :: proc(s: ^stmt, idx: i32, iValue: i64) -> Result ---
	bind_null :: proc(s: ^stmt, idx: i32) -> Result ---
	bind_text :: proc(s: ^stmt, idx: i32, data: cstring, n: i32, xDel: proc(ptr: rawptr) = nil) -> Result ---
	// omit bind_text16 :: proc()
	bind_text64 :: proc(s: ^stmt, idx: i32, data: cstring, n: u64, xDel: proc(ptr: rawptr) = nil, encoding: Encoding = .UTF8) -> Result ---
	bind_value :: proc(s: ^stmt, idx: i32, pValue: value) -> Result ---
	bind_pointer :: proc(s: ^stmt, idx: i32, ptr: rawptr, type: cstring, xDestructor: proc(ptr: rawptr)) -> Result ---
	bind_zeroblob :: proc(s: ^stmt, idx: i32, n: i32) -> Result ---
	bind_zeroblob64 :: proc(s: ^stmt, idx: i32, n: u64) -> Result ---

	bind_parameter_count :: proc(s: ^stmt) -> (count: i32) ---
	bind_parameter_name :: proc(s: ^stmt, idx: i32) -> (name: cstring) ---
	bind_parameter_index :: proc(s: ^stmt, name: cstring) -> (idx: i32) ---

	clear_bindings :: proc(s: ^stmt) -> Result ---
	column_count :: proc(s: ^stmt) -> (count: i32) ---

	column_name :: proc(s: ^stmt, column: i32) -> (name: cstring) ---
	// omit column_name16

	column_database_name :: proc(s: ^stmt, column: i32) -> (name: cstring) ---
	column_table_name :: proc(s: ^stmt, column: i32) -> (name: cstring) ---
	column_origin_name :: proc(s: ^stmt, column: i32) -> (name: cstring) ---
	// omit column_database_name16
	// omit column_table_name16
	// omit column_origin_name16

	column_decltype :: proc(s: ^stmt, column: i32) -> (type: cstring) ---
	// omit column_decltype16

	step :: proc(s: ^stmt) -> Result ---
	data_count :: proc(s: ^stmt) -> (count: i32) ---

	column_blob :: proc(s: ^stmt, iCol: i32) -> rawptr ---
	column_double :: proc(s: ^stmt, iCol: i32) -> f64 ---
	column_int :: proc(s: ^stmt, iCol: i32) -> i32 ---
	column_int64 :: proc(s: ^stmt, iCol: i32) -> i64 ---
	column_text :: proc(s: ^stmt, iCol: i32) -> cstring ---
	// omit column_text16 :: proc(s: ^stmt, iCol: i32) -> rawptr ---
	column_value :: proc(s: ^stmt, iCol: i32) -> ^value ---
	column_bytes :: proc(s: ^stmt, iCol: i32) -> i32 ---
	column_bytes16 :: proc(s: ^stmt, iCol: i32) -> i32 ---
	column_type :: proc(s: ^stmt, iCol: i32) -> Data_Type ---
	finalize :: proc(s: ^stmt) -> Result ---
	reset :: proc(s: ^stmt) -> Result ---


	create_function :: proc(db: ^sqlite3, function_name: cstring, arg: i32, text_rep: i32, app: rawptr, func: proc(ctx: ^fn_context, val: ^^value), step: proc(ctx: ^fn_context, val: ^^value), final: proc(ctx: ^fn_context)) -> Result ---
	// omit create_function16 ---
	create_function_v2 :: proc(db: ^sqlite3, function_name: cstring, arg: i32, text_rep: i32, app: rawptr, func: proc(ctx: ^fn_context, val: ^^value), step: proc(ctx: ^fn_context, val: ^^value), final: proc(ctx: ^fn_context), destroy: proc(app: rawptr)) -> Result ---
	create_window_function :: proc(db: ^sqlite3, function_name: cstring, arg: i32, text_rep: i32, app: rawptr, step: proc(ctx: ^fn_context, val: ^^value), final: proc(ctx: ^fn_context), value: proc(ctx: ^fn_context), inverse: proc(ctx: ^fn_context, val: ^^value), destroy: proc(app: rawptr)) -> Result ---

	value_blob :: proc(val: ^value) -> rawptr ---
	value_double :: proc(val: ^value) -> f64 ---
	value_int :: proc(val: ^value) -> i32 ---
	value_int64 :: proc(val: ^value) -> i64 ---
	value_pointer :: proc(val: ^value, type: cstring) -> rawptr ---
	value_text :: proc(val: ^value) -> cstring ---
	// omit value_text16 :: proc(val: ^value) -> rawptr ---
	// omit value_text16le :: proc(val: ^value) -> rawptr ---
	// omit value_text16be :: proc(val: ^value) -> rawptr ---
	value_bytes :: proc(val: ^value) -> i32 ---
	value_bytes16 :: proc(val: ^value) -> i32 ---
	value_type :: proc(val: ^value) -> i32 ---
	value_numeric_type :: proc(val: ^value) -> i32 ---
	value_nochange :: proc(val: ^value) -> i32 ---
	value_frombind :: proc(val: ^value) -> i32 ---

	value_encoding :: proc(val: ^value) -> Encoding ---
	value_subtype :: proc(val: ^value) -> u32 ---

	value_dup :: proc(val: ^value) -> ^value ---
	value_free :: proc(val: ^value) ---

	aggregate_context :: proc(ctx: ^fn_context, bytes: i32) -> rawptr ---

	user_data :: proc(ctx: ^fn_context) -> rawptr ---

	context_db_handle :: proc(ctx: ^fn_context) -> ^fn_context ---

	get_auxdata :: proc(ctx: ^fn_context, arg: i32) -> rawptr ---
	set_auxdata :: proc(ctx: ^fn_context, arg: i32, aux: rawptr, delete: proc(aux: rawptr)) ---

	get_clientdata :: proc(db: ^sqlite3, name: cstring) -> rawptr ---
	set_clientdata :: proc(db: ^sqlite3, name: cstring, data: rawptr, destructor: proc(_: rawptr)) -> Result ---

	result_blob :: proc(ctx: ^fn_context, blob: rawptr, n: int, xDel: proc(ptr: rawptr)) ---
	result_blob64 :: proc(ctx: ^fn_context, blob: rawptr, n: u64, xDel: proc(ptr: rawptr)) ---
	result_double :: proc(ctx: ^fn_context, val: f64) ---
	result_error :: proc(ctx: ^fn_context, cstring, n: i32) ---
	// omit result_error16 :: proc(ctx: ^fn_context, rawptr, int) ---
	result_error_toobig :: proc(ctx: ^fn_context) ---
	result_error_nomem :: proc(ctx: ^fn_context) ---
	result_error_code :: proc(ctx: ^fn_context, error_code: Result) ---
	result_int :: proc(ctx: ^fn_context, val: int) ---
	result_int64 :: proc(ctx: ^fn_context, val: i64) ---
	result_null :: proc(ctx: ^fn_context) ---
	result_text :: proc(ctx: ^fn_context, val: cstring, n: int, xDel: proc(ptr: rawptr)) ---
	result_text64 :: proc(ctx: ^fn_context, val: cstring, n: u64, xDel: proc(ptr: rawptr), encoding: Encoding) ---
	// omit result_text16 :: proc(ctx: ^fn_context, rawptr, int, void(*)(void*)) ---
	// omit result_text16le :: proc(ctx: ^fn_context, rawptr, int,void(*)(void*)) ---
	// omit result_text16be :: proc(ctx: ^fn_context, rawptr, int,void(*)(void*)) ---
	result_value :: proc(ctx: ^fn_context, val: ^value) ---
	result_pointer :: proc(ctx: ^fn_context, ptr: rawptr, type: cstring, xDestructor: proc(ptr: rawptr)) ---
	result_zeroblob :: proc(ctx: ^fn_context, n: i32) ---
	result_zeroblob64 :: proc(ctx: ^fn_context, n: u64) -> i32 ---

	result_subtype :: proc(ctx: ^fn_context, type: i32) ---

	create_collation :: proc(db: ^sqlite3, name: cstring, text_rep: i32, arg: rawptr, compare: proc(_: rawptr, _: i32, _: rawptr, _: i32, _: rawptr) -> i32) -> Result ---

	create_collation_v2 :: proc(db: ^sqlite3, name: cstring, text_rep: i32, arg: rawptr, compare: proc(_: rawptr, _: i32, _: rawptr, _: i32, _: rawptr) -> i32, destroy: proc(_: rawptr)) -> Result ---

	// omit create_collation16

	collation_needed :: proc(db: ^sqlite3, coll_needed_arg: rawptr, coll_needed: proc(_: rawptr, db: ^sqlite3, text_rep: i32, _: cstring)) -> Result ---
	// omit collation_needed16

	sleep :: proc(ms: i32) -> Result ---

	// --- DO NOT USE ---
	temp_directory: cstring
	// --- DO NOT USE ---
	data_directory: cstring

	when ODIN_OS == .Windows {
		win32_set_directory :: proc(type: Win32_Directory_Type, /* Identifier for directory being set or reset */
			value: rawptr, /* New value for directory being set or reset */) -> Result ---
		win32_set_directory8 :: proc(type: Win32_Directory_Type, value: cstring) -> Result ---
		// omit win32_set_directory16 :: proc(type: i32, value: rawptr) -> Result ---
	}

	get_autocommit :: proc(db: ^sqlite3) -> Result ---
	db_handle :: proc(s: ^stmt) -> ^sqlite3 ---
	db_name :: proc(db: ^sqlite3, idx: int) -> cstring ---
	db_filename :: proc(db: ^sqlite3, db_name: cstring) -> cstring ---
	// 1: read-only, 0: read-write, -1: not a database on connection `db`
	db_readonly :: proc(db: ^sqlite3, db_name: cstring) -> i32 ---
	txn_state :: proc(db: ^sqlite3, schema: cstring) -> Txn_State ---
	next_stmt :: proc(db: ^sqlite3, s: ^stmt) -> ^stmt ---

	commit_hook :: proc(db: ^sqlite3, callback: proc(_: rawptr) -> Result, arg: rawptr) -> rawptr ---
	rollback_hook :: proc(db: ^sqlite3, callback: proc(_: rawptr), arg: rawptr) -> rawptr ---

	autovacuum_pages :: proc(db: ^sqlite3, callback: proc(_: rawptr, _: cstring, _: u32, _: u32, _: u32) -> u32, arg: rawptr, destructor: proc(arg: rawptr)) -> Result ---

	update_hook :: proc(db: ^sqlite3, callback: proc(_: rawptr, _: i32, _: cstring, _: cstring, _: i64), arg: rawptr) -> rawptr ---

	enable_shared_cache :: proc(enable: i32) -> (enabled: b32) ---
	release_memory :: proc(n: i32) -> (freed: i32) ---
	db_release_memory :: proc(db: ^sqlite3) -> Result ---

	soft_heap_limit64 :: proc(n: i64) -> i64 ---
	hard_heap_limit64 :: proc(n: i64) -> i64 ---

	table_column_metadata :: proc(db: ^sqlite3, /* Connection handle */
		db_name: cstring, /* Database name or NULL */
		table_name: cstring, /* Table name */
		col_name: cstring, /* Column name */
		data_type: [^]cstring, /* OUTPUT: Declared data type */
		coll_seq: [^]cstring, /* OUTPUT: Collation sequence name */
		not_null: ^i32, /* OUTPUT: True if NOT NULL constraint exists */
		primary_key: ^i32, /* OUTPUT: True if column part of PK */
		auto_inc: ^i32, /* OUTPUT: True if column is auto-increment */) -> Result ---

	load_extension :: proc(db: ^sqlite3, /* Load the extension into this database connection */
		file: cstring, /* Name of the shared library containing extension */
		procedure: cstring, /* Entry point.  Derived from zFile if 0 */
		err_msg: [^]cstring, /* Put error message here if not 0 */) -> Result ---

	enable_load_extension :: proc(db: ^sqlite3, onoff: b32) -> Result ---

	// The following two procs oughta be checked again as the entry point's signature is not a true sig
	auto_extension :: proc(entry_point: proc()) -> Result ---
	cancel_auto_extension :: proc(entry_point: proc()) -> Result ---
	reset_auto_extension :: proc() ---

	create_module :: proc(db: ^sqlite3, /* SQLite connection to register module with */
		name: cstring, /* Name of the module */
		module: ^module, /* Methods for the module */
		client_data: rawptr, /* Client data for xCreate/xConnect */) -> Result ---
	create_module_v2 :: proc(db: ^sqlite3, /* SQLite connection to register module with */
		name: cstring, /* Name of the module */
		module: ^module, /* Methods for the module */
		client_data: rawptr, /* Client data for xCreate/xConnect */
		destroy: proc(_: rawptr), /* Module destructor function */) -> Result ---

	/* db: Remove modules from this connection */
	/* keep: Except, do not remove the ones named here */
	drop_modules :: proc(db: ^sqlite3, keep: [^]cstring) -> Result ---
	declare_vtab :: proc(db: ^sqlite3, sql: cstring) -> Result ---
	overload_function :: proc(db: ^sqlite3, func_name: cstring, arg: i32) -> Result ---

	blob_open :: proc(db: ^sqlite3, db_name: cstring, table: cstring, column: cstring, row: i64, flags: b32, blob: ^^blob) -> Result ---
	blob_reopen :: proc(blob: ^blob, row: i64) -> Result ---
	blob_close :: proc(blob: ^blob) -> Result ---
	blob_bytes :: proc(blob: ^blob) -> i32 ---
	blob_read :: proc(blob: ^blob, buffer: rawptr, n: i32, offset: i32) -> Result ---
	blob_write :: proc(blob: ^blob, buffer: rawptr, n: i32, offset: i32) -> Result ---

	vfs_find :: proc(vfs_name: cstring) -> ^vfs ---
	vfs_register :: proc(vfs: ^vfs, make_default: b32) -> Result ---
	vfs_unregister :: proc(vfs: ^vfs) -> Result ---

	// --- MUTEX ---
	mutex_alloc :: proc(id: Mutex_Type) -> ^mutex ---
	mutex_free :: proc(mutex: ^mutex) ---
	mutex_enter :: proc(mutex: ^mutex) ---
	mutex_try :: proc(mutex: ^mutex) -> Result ---
	mutex_leave :: proc(mutex: ^mutex) ---

	db_mutex :: proc(db: ^sqlite3) -> ^mutex ---

	file_control :: proc(db: ^sqlite3, db_name: cstring, op_code: File_Control_Code, arg: rawptr) ---
	// omit test_control

	keyword_count :: proc() -> i32 ---
	keyword_name :: proc(idx: i32, name: ^cstring, length: ^i32) -> Result ---
	keyword_check :: proc(name: cstring, length: i32) -> b32 ---

	// these are unnecessary
	// str_new :: proc(db: ^sqlite3) -> ^str ---
	// str_finish:: proc(str: ^str) -> cstring ---
	// str_appendf:: proc(str: ^str, format: cstring, #c_vararg values: ..any) ---
	// str_vappendf:: proc(str: ^str, format: cstring, args: libc.va_list) ---
	// str_append:: proc(str: ^str, in_str: cstring, length: i32) ---
	// str_appendall:: proc(str: ^str, in_str: cstring) ---
	// str_appendchar:: proc(str: ^str, char_count: i32, char: u8) ---
	// str_reset:: proc(str: ^str) ---
	// str_errcode:: proc(str: ^str) -> Result ---
	// str_length:: proc(str: ^str) -> i32 ---
	// str_value:: proc(str: ^str) -> cstring ---

	status :: proc(op_code: Status_Code, current: ^i32, highwater: ^i32, reset_flag: b32) -> Result ---
	status64 :: proc(op_code: Status_Code, current: ^i64, highwater: ^i64, resetFlag: b32) -> Result ---
	db_status :: proc(db: ^sqlite3, op_code: Db_Status_Code, current: ^i32, highwater: ^i32, reset_flag: b32) -> Result ---
	stmt_status :: proc(s: ^stmt, op_code: Stmt_Status_Code, reset_flag: b32) -> i32 ---

	// --- BACKUP ---
	backup_init :: proc(dest_db: ^sqlite3, /* Destination database handle */
		dest_name: cstring, /* Destination database name */
		src_db: ^sqlite3, /* Source database handle */
		src_name: cstring, /* Source database name */) -> ^backup ---
	backup_step :: proc(backup: ^backup, page: i32) -> Result ---
	backup_finish :: proc(backup: ^backup) -> Result ---
	backup_remaining :: proc(backup: ^backup) -> i32 ---
	backup_pagecount :: proc(backup: ^backup) -> i32 ---

	unlock_notify :: proc(blocked: ^sqlite3, /* Waiting connection */
		notify: proc(arg: [^]rawptr, n: i32), /* Callback function to invoke */
		notify_arg: rawptr, /* Argument to pass to xNotify */) -> Result ---

	// these are unnecessary
	// stricmp :: proc(_: cstring, _: cstring) -> i32 ---
	// strnicmp :: proc(_: cstring, _: cstring, i32) -> i32 ---
	// strglob :: proc(glob: cstring, str: cstring) -> i32 ---
	// strlike :: proc(glob: cstring, str: cstring, esc: u32) -> i32 ---
	// log(err_code: i32, format: cstring, #c_vararg args: ..any) ---

	wal_hook :: proc(db: ^sqlite3, callback: proc(wal_arg: rawptr, db: ^sqlite3, db_name: cstring, pages: i32) -> Result, wal_arg: rawptr) -> rawptr ---
	wal_autocheckpoint :: proc(db: ^sqlite3, frame: i32) -> Result ---
	wal_checkpoint :: proc(db: ^sqlite3, db_name: cstring) -> Result ---
	wal_checkpoint_v2 :: proc(db: ^sqlite3, /* Database handle */
		db_name: cstring, /* Name of attached database (or NULL) */
		mode: i32, /* SQLITE_CHECKPOINT_* value */
		log: ^i32, /* OUT: Size of WAL log in frames */
		checkpoint: ^i32, /* OUT: Total number of frames checkpointed */) -> Result ---

	// --- VTAB ---
	vtab_config :: proc(db: ^sqlite3, op_code: Vtab_Option, #c_vararg options: ..any) -> i32 ---
	vtab_on_conflict :: proc(db: ^sqlite3) -> Conflict_Res_Mode ---
	vtab_nochange :: proc(ctx: ^fn_context) -> b32 ---
	vtab_collation :: proc(index_info: ^index_info, constraint_idx: i32) -> cstring ---
	vtab_distinct :: proc(index_info: ^index_info) -> i32 ---
	vtab_in :: proc(index_info: ^index_info, constraint_idx: i32, handle: b32) -> b32 ---
	vtab_in_first :: proc(val: ^value, out: ^^value) -> Result ---
	vtab_in_next :: proc(val: ^value, out: ^^value) -> Result ---
	vtab_rhs_value :: proc(index_info: ^index_info, constraint_idx: i32, val: ^^value) -> Result ---

	stmt_scanstatus :: proc(s: ^stmt, /* Prepared statement for which info desired */
		idx: i32, /* Index of loop to report on */
		op_code: Scan_Status_Code, /* Information desired.  SQLITE_SCANSTAT_* */
		out: rawptr, /* Result written here */) -> Result ---
	stmt_scanstatus_v2 :: proc(s: ^stmt, /* Prepared statement for which info desired */
		idx: i32, /* Index of loop to report on */
		op_code: Scan_Status_Code, /* Information desired.  SQLITE_SCANSTAT_* */
		flags: Scan_Status_Flag, /* Mask of flags defined below */
		out: rawptr, /* Result written here */) -> Result ---
	stmt_scanstatus_reset :: proc(s: ^stmt) ---
	db_cacheflush :: proc(db: ^sqlite3) -> Result ---
	system_errno :: proc(db: ^sqlite3) -> Result ---


	serialize :: proc(db: ^sqlite3, /* The database connection */
		schema: cstring, /* Which DB to serialize. ex: "main", "temp", ... */
		size: ^i64, /* Write size of the DB here, if not NULL */
		flags: Serialize_Flag, /* Zero or more SQLITE_SERIALIZE_* flags */) -> cstring ---
	deserialize :: proc(db: ^sqlite3, /* The database connection */
		schema: cstring, /* Which DB to reopen with the deserialization */
		data: cstring, /* The serialized database content */
		byte_count: i64, /* Number bytes in the deserialization */
		buffer_size: i64, /* Total size of buffer pData[] */
		flags: Deserialize_Flag, /* Zero or more SQLITE_DESERIALIZE_* flags */) -> Result ---
}


Result :: enum i32 {
	OK                      = 0, /* Successful result */
	ERROR                   = 1, /* Generic error */
	INTERNAL                = 2, /* Internal logic error in SQLite */
	PERM                    = 3, /* Access permission denied */
	ABORT                   = 4, /* Callback routine requested an abort */
	BUSY                    = 5, /* The database file is locked */
	LOCKED                  = 6, /* A table in the database is locked */
	NOMEM                   = 7, /* A malloc() failed */
	READONLY                = 8, /* Attempt to write a readonly database */
	INTERRUPT               = 9, /* Operation terminated by interrupt()*/
	IOERR                   = 10, /* Some kind of disk I/O error occurred */
	CORRUPT                 = 11, /* The database disk image is malformed */
	NOTFOUND                = 12, /* Unknown opcode in file_control() */
	FULL                    = 13, /* Insertion failed because database is full */
	CANTOPEN                = 14, /* Unable to open the database file */
	PROTOCOL                = 15, /* Database lock protocol error */
	EMPTY                   = 16, /* Internal use only */
	SCHEMA                  = 17, /* The database schema changed */
	TOOBIG                  = 18, /* String or BLOB exceeds size limit */
	CONSTRAINT              = 19, /* Abort due to constraint violation */
	MISMATCH                = 20, /* Data type mismatch */
	MISUSE                  = 21, /* Library used incorrectly */
	NOLFS                   = 22, /* Uses OS features not supported on host */
	AUTH                    = 23, /* Authorization denied */
	FORMAT                  = 24, /* Not used */
	RANGE                   = 25, /* 2nd parameter to bind out of range */
	NOTADB                  = 26, /* File opened that is not a database file */
	NOTICE                  = 27, /* Notifications from log() */
	WARNING                 = 28, /* Warnings from log() */
	ROW                     = 100, /* step() has another row ready */
	DONE                    = 101, /* step() has finished executing */

	// Extended Error Codes
	ERROR_MISSING_COLLSEQ   = (ERROR | (1 << 8)),
	ERROR_RETRY             = (ERROR | (2 << 8)),
	ERROR_SNAPSHOT          = (ERROR | (3 << 8)),
	IOERR_READ              = (IOERR | (1 << 8)),
	IOERR_SHORT_READ        = (IOERR | (2 << 8)),
	IOERR_WRITE             = (IOERR | (3 << 8)),
	IOERR_FSYNC             = (IOERR | (4 << 8)),
	IOERR_DIR_FSYNC         = (IOERR | (5 << 8)),
	IOERR_TRUNCATE          = (IOERR | (6 << 8)),
	IOERR_FSTAT             = (IOERR | (7 << 8)),
	IOERR_UNLOCK            = (IOERR | (8 << 8)),
	IOERR_RDLOCK            = (IOERR | (9 << 8)),
	IOERR_DELETE            = (IOERR | (10 << 8)),
	IOERR_BLOCKED           = (IOERR | (11 << 8)),
	IOERR_NOMEM             = (IOERR | (12 << 8)),
	IOERR_ACCESS            = (IOERR | (13 << 8)),
	IOERR_CHECKRESERVEDLOCK = (IOERR | (14 << 8)),
	IOERR_LOCK              = (IOERR | (15 << 8)),
	IOERR_CLOSE             = (IOERR | (16 << 8)),
	IOERR_DIR_CLOSE         = (IOERR | (17 << 8)),
	IOERR_SHMOPEN           = (IOERR | (18 << 8)),
	IOERR_SHMSIZE           = (IOERR | (19 << 8)),
	IOERR_SHMLOCK           = (IOERR | (20 << 8)),
	IOERR_SHMMAP            = (IOERR | (21 << 8)),
	IOERR_SEEK              = (IOERR | (22 << 8)),
	IOERR_DELETE_NOENT      = (IOERR | (23 << 8)),
	IOERR_MMAP              = (IOERR | (24 << 8)),
	IOERR_GETTEMPPATH       = (IOERR | (25 << 8)),
	IOERR_CONVPATH          = (IOERR | (26 << 8)),
	IOERR_VNODE             = (IOERR | (27 << 8)),
	IOERR_AUTH              = (IOERR | (28 << 8)),
	IOERR_BEGIN_ATOMIC      = (IOERR | (29 << 8)),
	IOERR_COMMIT_ATOMIC     = (IOERR | (30 << 8)),
	IOERR_ROLLBACK_ATOMIC   = (IOERR | (31 << 8)),
	IOERR_DATA              = (IOERR | (32 << 8)),
	IOERR_CORRUPTFS         = (IOERR | (33 << 8)),
	IOERR_IN_PAGE           = (IOERR | (34 << 8)),
	LOCKED_SHAREDCACHE      = (LOCKED | (1 << 8)),
	LOCKED_VTAB             = (LOCKED | (2 << 8)),
	BUSY_RECOVERY           = (BUSY | (1 << 8)),
	BUSY_SNAPSHOT           = (BUSY | (2 << 8)),
	BUSY_TIMEOUT            = (BUSY | (3 << 8)),
	CANTOPEN_NOTEMPDIR      = (CANTOPEN | (1 << 8)),
	CANTOPEN_ISDIR          = (CANTOPEN | (2 << 8)),
	CANTOPEN_FULLPATH       = (CANTOPEN | (3 << 8)),
	CANTOPEN_CONVPATH       = (CANTOPEN | (4 << 8)),
	CANTOPEN_DIRTYWAL       = (CANTOPEN | (5 << 8)), /* Not Used */
	CANTOPEN_SYMLINK        = (CANTOPEN | (6 << 8)),
	CORRUPT_VTAB            = (CORRUPT | (1 << 8)),
	CORRUPT_SEQUENCE        = (CORRUPT | (2 << 8)),
	CORRUPT_INDEX           = (CORRUPT | (3 << 8)),
	READONLY_RECOVERY       = (READONLY | (1 << 8)),
	READONLY_CANTLOCK       = (READONLY | (2 << 8)),
	READONLY_ROLLBACK       = (READONLY | (3 << 8)),
	READONLY_DBMOVED        = (READONLY | (4 << 8)),
	READONLY_CANTINIT       = (READONLY | (5 << 8)),
	READONLY_DIRECTORY      = (READONLY | (6 << 8)),
	ABORT_ROLLBACK          = (ABORT | (2 << 8)),
	CONSTRAINT_CHECK        = (CONSTRAINT | (1 << 8)),
	CONSTRAINT_COMMITHOOK   = (CONSTRAINT | (2 << 8)),
	CONSTRAINT_FOREIGNKEY   = (CONSTRAINT | (3 << 8)),
	CONSTRAINT_FUNCTION     = (CONSTRAINT | (4 << 8)),
	CONSTRAINT_NOTNULL      = (CONSTRAINT | (5 << 8)),
	CONSTRAINT_PRIMARYKEY   = (CONSTRAINT | (6 << 8)),
	CONSTRAINT_TRIGGER      = (CONSTRAINT | (7 << 8)),
	CONSTRAINT_UNIQUE       = (CONSTRAINT | (8 << 8)),
	CONSTRAINT_VTAB         = (CONSTRAINT | (9 << 8)),
	CONSTRAINT_ROWID        = (CONSTRAINT | (10 << 8)),
	CONSTRAINT_PINNED       = (CONSTRAINT | (11 << 8)),
	CONSTRAINT_DATATYPE     = (CONSTRAINT | (12 << 8)),
	NOTICE_RECOVER_WAL      = (NOTICE | (1 << 8)),
	NOTICE_RECOVER_ROLLBACK = (NOTICE | (2 << 8)),
	NOTICE_RBU              = (NOTICE | (3 << 8)),
	WARNING_AUTOINDEX       = (WARNING | (1 << 8)),
	AUTH_USER               = (AUTH | (1 << 8)),
	OK_LOAD_PERMANENTLY     = (OK | (1 << 8)),
	OK_SYMLINK              = (OK | (2 << 8)), /* internal use only */
}

Open_Flags :: enum i32 {
	READONLY       = 0x00000001, /* Ok for open_v2() */
	READWRITE      = 0x00000002, /* Ok for open_v2() */
	CREATE         = 0x00000004, /* Ok for open_v2() */
	DELETEONCLOSE  = 0x00000008, /* VFS only */
	EXCLUSIVE      = 0x00000010, /* VFS only */
	AUTOPROXY      = 0x00000020, /* VFS only */
	URI            = 0x00000040, /* Ok for open_v2() */
	MEMORY         = 0x00000080, /* Ok for open_v2() */
	MAIN_DB        = 0x00000100, /* VFS only */
	TEMP_DB        = 0x00000200, /* VFS only */
	TRANSIENT_DB   = 0x00000400, /* VFS only */
	MAIN_JOURNAL   = 0x00000800, /* VFS only */
	TEMP_JOURNAL   = 0x00001000, /* VFS only */
	SUBJOURNAL     = 0x00002000, /* VFS only */
	SUPER_JOURNAL  = 0x00004000, /* VFS only */
	NOMUTEX        = 0x00008000, /* Ok for open_v2() */
	FULLMUTEX      = 0x00010000, /* Ok for open_v2() */
	SHAREDCACHE    = 0x00020000, /* Ok for open_v2() */
	PRIVATECACHE   = 0x00040000, /* Ok for open_v2() */
	WAL            = 0x00080000, /* VFS only */
	NOFOLLOW       = 0x01000000, /* Ok for open_v2() */
	EXRESCODE      = 0x02000000, /* Extended result codes */
	/* Reserved:                         0x00F00000 */
	/* Legacy compatibility: */
	MASTER_JOURNAL = 0x00004000, /* VFS only */
}

Io_Cap :: enum u16 {
	ATOMIC                = 0x00000001,
	ATOMIC512             = 0x00000002,
	ATOMIC1K              = 0x00000004,
	ATOMIC2K              = 0x00000008,
	ATOMIC4K              = 0x00000010,
	ATOMIC8K              = 0x00000020,
	ATOMIC16K             = 0x00000040,
	ATOMIC32K             = 0x00000080,
	ATOMIC64K             = 0x00000100,
	SAFE_APPEND           = 0x00000200,
	SEQUENTIAL            = 0x00000400,
	UNDELETABLE_WHEN_OPEN = 0x00000800,
	POWERSAFE_OVERWRITE   = 0x00001000,
	IMMUTABLE             = 0x00002000,
	BATCH_ATOMIC          = 0x00004000,
}

File_Lock :: enum u8 {
	NONE      = 0, /* xUnlock() only */
	SHARED    = 1, /* xLock() or xUnlock() */
	RESERVED  = 2, /* xLock() only */
	PENDING   = 3, /* xLock() only */
	EXCLUSIVE = 4, /* xLock() only */
}

Sync_Type :: enum u8 {
	NORMAL   = 0x00002,
	FULL     = 0x00003,
	DATAONLY = 0x00010,
}

Config :: enum i32 {
	SINGLETHREAD        = 1, /* nil */
	MULTITHREAD         = 2, /* nil */
	SERIALIZED          = 3, /* nil */
	MALLOC              = 4, /* mem_methods* */
	GETMALLOC           = 5, /* mem_methods* */
	SCRATCH             = 6, /* No longer used */
	PAGECACHE           = 7, /* void*, int sz, int N */
	HEAP                = 8, /* void*, int nByte, int min */
	MEMSTATUS           = 9, /* boolean */
	MUTEX               = 10, /* mutex_methods* */
	GETMUTEX            = 11, /* mutex_methods* */
	LOOKASIDE           = 13, /* int int */
	PCACHE              = 14, /* no-op */
	GETPCACHE           = 15, /* no-op */
	LOG                 = 16, /* xFunc, void* */
	URI                 = 17, /* int */
	PCACHE2             = 18, /* pcache_methods2* */
	GETPCACHE2          = 19, /* pcache_methods2* */
	COVERING_INDEX_SCAN = 20, /* int */
	SQLLOG              = 21, /* xSqllog, void* */
	MMAP_SIZE           = 22, /* int64, int64 */
	WIN32_HEAPSIZE      = 23, /* int nByte */
	PCACHE_HDRSZ        = 24, /* int *psz */
	PMASZ               = 25, /* unsigned int szPma */
	STMTJRNL_SPILL      = 26, /* int nByte */
	SMALL_MALLOC        = 27, /* boolean */
	SORTERREF_SIZE      = 28, /* int nByte */
	MEMDB_MAXSIZE       = 29, /* int64 */
	ROWID_IN_VIEW       = 30, /* int* */
}

Db_Config :: enum i32 {
	MAINDBNAME            = 1000, /* const char* */
	LOOKASIDE             = 1001, /* void* int int */
	ENABLE_FKEY           = 1002, /* int int* */
	ENABLE_TRIGGER        = 1003, /* int int* */
	ENABLE_FTS3_TOKENIZER = 1004, /* int int* */
	ENABLE_LOAD_EXTENSION = 1005, /* int int* */
	NO_CKPT_ON_CLOSE      = 1006, /* int int* */
	ENABLE_QPSG           = 1007, /* int int* */
	TRIGGER_EQP           = 1008, /* int int* */
	RESET_DATABASE        = 1009, /* int int* */
	DEFENSIVE             = 1010, /* int int* */
	WRITABLE_SCHEMA       = 1011, /* int int* */
	LEGACY_ALTER_TABLE    = 1012, /* int int* */
	DQS_DML               = 1013, /* int int* */
	DQS_DDL               = 1014, /* int int* */
	ENABLE_VIEW           = 1015, /* int int* */
	LEGACY_FILE_FORMAT    = 1016, /* int int* */
	TRUSTED_SCHEMA        = 1017, /* int int* */
	STMT_SCANSTATUS       = 1018, /* int int* */
	REVERSE_SCANORDER     = 1019, /* int int* */
}

Trace :: enum i32 {
	STMT    = 0x01,
	PROFILE = 0x02,
	ROW     = 0x04,
	CLOSE   = 0x08,
}


Limit_Category :: enum i32 {
	LENGTH              = 0,
	SQL_LENGTH          = 1,
	COLUMN              = 2,
	EXPR_DEPTH          = 3,
	COMPOUND_SELECT     = 4,
	VDBE_OP             = 5,
	FUNCTION_ARG        = 6,
	ATTACHED            = 7,
	LIKE_PATTERN_LENGTH = 8,
	VARIABLE_NUMBER     = 9,
	TRIGGER_DEPTH       = 10,
	WORKER_THREADS      = 11,
}


// LIMIT_LENGTH :: Limit_Category.LENGTH
// LIMIT_SQL_LENGTH :: Limit_Category.SQL_LENGTH
// LIMIT_COLUMN :: Limit_Category.COLUMN
// LIMIT_EXPR_DEPTH :: Limit_Category.EXPR_DEPTH
// LIMIT_COMPOUND_SELECT :: Limit_Category.COMPOUND_SELECT
// LIMIT_VDBE_OP :: Limit_Category.VDBE_OP
// LIMIT_FUNCTION_ARG :: Limit_Category.FUNCTION_ARG
// LIMIT_ATTACHED :: Limit_Category.ATTACHED
// LIMIT_LIKE_PATTERN_LENGTH :: Limit_Category.LIKE_PATTERN_LENGTH
// LIMIT_VARIABLE_NUMBER :: Limit_Category.VARIABLE_NUMBER
// LIMIT_TRIGGER_DEPTH :: Limit_Category.TRIGGER_DEPTH
// LIMIT_WORKER_THREADS :: Limit_Category.WORKER_THREADS
// N_LIMIT :: len(Limit_Category) + 1

Prepare_Flag :: enum i32 {
	PERSISTENT = 0x01,
	NORMALIZE  = 0x02,
	NO_VTAB    = 0x04,
}

Data_Type :: enum i32 {
	INTEGER = 1,
	FLOAT   = 2,
	TEXT    = 3,
	BLOB    = 4,
	NULL    = 5,
}

Encoding :: enum u8 {
	UTF8          = 1, /* IMP: R-37514-35566 */
	UTF16LE       = 2, /* IMP: R-03371-37637 */
	UTF16BE       = 3, /* IMP: R-51971-34154 */
	UTF16         = 4, /* Use native byte order */
	ANY           = 5, /* Deprecated */
	UTF16_ALIGNED = 8, /* create_collation only */
}

Function_Flag :: enum i32 {
	DETERMINISTIC  = 0x000000800,
	DIRECTONLY     = 0x000080000,
	SUBTYPE        = 0x000100000,
	INNOCUOUS      = 0x000200000,
	RESULT_SUBTYPE = 0x001000000,
	SELFORDER1     = 0x002000000,
}

Txn_State :: enum i32 {
	NONE  = 0,
	READ  = 1,
	WRITE = 2,
}

Mutex_Type :: enum i32 {
	FAST          = 0,
	RECURSIVE     = 1,
	STATIC_MAIN   = 2,
	STATIC_MEM    = 3, /* malloc() */
	STATIC_MEM2   = 4, /* NOT USED */
	STATIC_OPEN   = 4, /* sqlite3BtreeOpen() */
	STATIC_PRNG   = 5, /* randomness() */
	STATIC_LRU    = 6, /* lru page list */
	STATIC_LRU2   = 7, /* NOT USED */
	STATIC_PMEM   = 7, /* sqlite3PageMalloc() */
	STATIC_APP1   = 8, /* For use by application */
	STATIC_APP2   = 9, /* For use by application */
	STATIC_APP3   = 10, /* For use by application */
	STATIC_VFS1   = 11, /* For use by built-in VFS */
	STATIC_VFS2   = 12, /* For use by extension VFS */
	STATIC_VFS3   = 13, /* For use by application VFS */

	/* Legacy compatibility: */
	STATIC_MASTER = 2,
}

Status_Code :: enum i32 {
	MEMORY_USED        = 0,
	PAGECACHE_USED     = 1,
	PAGECACHE_OVERFLOW = 2,
	SCRATCH_USED       = 3, /* NOT USED */
	SCRATCH_OVERFLOW   = 4, /* NOT USED */
	MALLOC_SIZE        = 5,
	PARSER_STACK       = 6,
	PAGECACHE_SIZE     = 7,
	SCRATCH_SIZE       = 8, /* NOT USED */
	MALLOC_COUNT       = 9,
}

Db_Status_Code :: enum i32 {
	LOOKASIDE_USED      = 0,
	CACHE_USED          = 1,
	SCHEMA_USED         = 2,
	STMT_USED           = 3,
	LOOKASIDE_HIT       = 4,
	LOOKASIDE_MISS_SIZE = 5,
	LOOKASIDE_MISS_FULL = 6,
	CACHE_HIT           = 7,
	CACHE_MISS          = 8,
	CACHE_WRITE         = 9,
	DEFERRED_FKS        = 10,
	CACHE_USED_SHARED   = 11,
	CACHE_SPILL         = 12,
}

Stmt_Status_Code :: enum i32 {
	FULLSCAN_STEP = 1,
	SORT          = 2,
	AUTOINDEX     = 3,
	VM_STEP       = 4,
	REPREPARE     = 5,
	RUN           = 6,
	FILTER_MISS   = 7,
	FILTER_HIT    = 8,
	MEMUSED       = 99,
}

Checkpoint_Mode :: enum i32 {
	PASSIVE  = 0, /* Do as much as possible w/o blocking */
	FULL     = 1, /* Wait for writers, then checkpoint */
	RESTART  = 2, /* Like FULL but wait for readers */
	TRUNCATE = 3, /* Like RESTART but also truncate WAL */
}

Vtab_Option :: enum i32 {
	CONSTRAINT_SUPPORT = 1,
	INNOCUOUS          = 2,
	DIRECTONLY         = 3,
	USES_ALL_SCHEMAS   = 4,
}

Conflict_Res_Mode :: enum i32 {
	ROLLBACK = 1,
	IGNORE   = 2,
	FAIL     = 3,
	ABORT    = 4,
	REPLACE  = 5,
}

Scan_Status_Code :: enum i32 {
	// --- Op Codes ---
	NLOOP    = 0,
	NVISIT   = 1,
	EST      = 2,
	NAME     = 3,
	EXPLAIN  = 4,
	SELECTID = 5,
	PARENTID = 6,
	NCYCLE   = 7,
}

Scan_Status_Flag :: enum i32 {
	NONE    = 0x0000,
	COMPLEX = 0x0001,
}

Serialize_Flag :: enum i32 {
	NONE   = 0x000,
	NOCOPY = 0x001, /* Do no memory allocations */
}

Deserialize_Flag :: enum i32 {
	NONE        = 0,
	FREEONCLOSE = 1, /* Call sqlite3.free() on close */
	RESIZEABLE  = 2, /* Resize using sqlite3.realloc64() */
	READONLY    = 4, /* Database is read-only */
}

File_Control_Code :: enum {
	LOCKSTATE             = 1,
	GET_LOCKPROXYFILE     = 2,
	SET_LOCKPROXYFILE     = 3,
	LAST_ERRNO            = 4,
	SIZE_HINT             = 5,
	CHUNK_SIZE            = 6,
	FILE_POINTER          = 7,
	SYNC_OMITTED          = 8,
	WIN32_AV_RETRY        = 9,
	PERSIST_WAL           = 10,
	OVERWRITE             = 11,
	VFSNAME               = 12,
	POWERSAFE_OVERWRITE   = 13,
	PRAGMA                = 14,
	BUSYHANDLER           = 15,
	TEMPFILENAME          = 16,
	MMAP_SIZE             = 18,
	TRACE                 = 19,
	HAS_MOVED             = 20,
	SYNC                  = 21,
	COMMIT_PHASETWO       = 22,
	WIN32_SET_HANDLE      = 23,
	WAL_BLOCK             = 24,
	ZIPVFS                = 25,
	RBU                   = 26,
	VFS_POINTER           = 27,
	JOURNAL_POINTER       = 28,
	WIN32_GET_HANDLE      = 29,
	PDB                   = 30,
	BEGIN_ATOMIC_WRITE    = 31,
	COMMIT_ATOMIC_WRITE   = 32,
	ROLLBACK_ATOMIC_WRITE = 33,
	LOCK_TIMEOUT          = 34,
	DATA_VERSION          = 35,
	SIZE_LIMIT            = 36,
	CKPT_DONE             = 37,
	RESERVE_BYTES         = 38,
	CKPT_START            = 39,
	EXTERNAL_READER       = 40,
	CKSM_FILE             = 41,
	RESET_CACHE           = 42,
}

Auth_Action_Code :: enum i32 {
	CREATE_INDEX        = 1, /* Index Name      Table Name      */
	CREATE_TABLE        = 2, /* Table Name      NULL            */
	CREATE_TEMP_INDEX   = 3, /* Index Name      Table Name      */
	CREATE_TEMP_TABLE   = 4, /* Table Name      NULL            */
	CREATE_TEMP_TRIGGER = 5, /* Trigger Name    Table Name      */
	CREATE_TEMP_VIEW    = 6, /* View Name       NULL            */
	CREATE_TRIGGER      = 7, /* Trigger Name    Table Name      */
	CREATE_VIEW         = 8, /* View Name       NULL            */
	DELETE              = 9, /* Table Name      NULL            */
	DROP_INDEX          = 10, /* Index Name      Table Name      */
	DROP_TABLE          = 11, /* Table Name      NULL            */
	DROP_TEMP_INDEX     = 12, /* Index Name      Table Name      */
	DROP_TEMP_TABLE     = 13, /* Table Name      NULL            */
	DROP_TEMP_TRIGGER   = 14, /* Trigger Name    Table Name      */
	DROP_TEMP_VIEW      = 15, /* View Name       NULL            */
	DROP_TRIGGER        = 16, /* Trigger Name    Table Name      */
	DROP_VIEW           = 17, /* View Name       NULL            */
	INSERT              = 18, /* Table Name      NULL            */
	PRAGMA              = 19, /* Pragma Name     1st arg or NULL */
	READ                = 20, /* Table Name      Column Name     */
	SELECT              = 21, /* NULL            NULL            */
	TRANSACTION         = 22, /* Operation       NULL            */
	UPDATE              = 23, /* Table Name      Column Name     */
	ATTACH              = 24, /* Filename        NULL            */
	DETACH              = 25, /* Database Name   NULL            */
	ALTER_TABLE         = 26, /* Database Name   Table Name      */
	REINDEX             = 27, /* Index Name      NULL            */
	ANALYZE             = 28, /* Table Name      NULL            */
	CREATE_VTABLE       = 29, /* Table Name      Module Name     */
	DROP_VTABLE         = 30, /* Table Name      Module Name     */
	FUNCTION            = 31, /* NULL            Function Name   */
	SAVEPOINT           = 32, /* Operation       Savepoint Name  */
	COPY                = 0, /* No longer used */
	RECURSIVE           = 33, /* NULL            NULL            */
}

Auth_Return_Code :: enum i32 {
	OK     = 0,
	DENY   = 1,
	IGNORE = 2,
}

Trace_Event_Code :: enum u32 {
	DISABLE = 0x00,
	STMT    = 0x01,
	PROFILE = 0x02,
	ROW     = 0x04,
	CLOSE   = 0x08,
}

sqlite3 :: struct {}
stmt :: struct {}
fn_context :: struct {} // context is keyword
module :: struct {}
blob :: struct {}
vfs :: struct {}
mutex :: struct {}
// str :: struct {}
backup :: struct {}
index_info :: struct {}

callback :: proc "c" (db: rawptr, col: i32, vals: [^]cstring, cols: [^]cstring) -> Result

value :: struct {
	u:        struct #raw_union {}, // MemValue
	z:        cstring, /* String or BLOB value */
	n:        i32, /* Number of characters in string value, excluding '\0' */
	flags:    u16, /* Some combination of MEM_Null, MEM_Str, MEM_Dyn, etc. */
	encoding: u8, /* SQLITE_UTF8, SQLITE_UTF16BE, SQLITE_UTF16LE */
	sub_type: u8, /* Subtype for this value */
}

mem_methods :: struct {
	malloc:   proc "c" (n: i32) -> rawptr, /* Memory allocation function */
	free:     proc "c" (ptr: rawptr), /* Free a prior allocation */
	realloc:  proc "c" (ptr: rawptr, n: i32) -> rawptr, /* Resize an allocation */
	size:     proc "c" (ptr: rawptr) -> i32, /* Return the size of an allocation */
	roundup:  proc "c" (n: i32) -> i32, /* Round up request size to allocation size */
	init:     proc "c" (appData: rawptr) -> i32, /* Initialize the memory allocator */
	shutdown: proc "c" (appData: rawptr), /* Deinitialize the memory allocator */
	appData:  rawptr, /* Argument to init() and shutdown() */
}


when ODIN_OS == .Windows {
	Win32_Directory_Type :: enum i32 {
		DATA = 1,
		TEMP = 2,
	}
}
