#+private
package sqlite3_odin_tests

import "base:runtime"
import "core:c"
import "core:c/libc"
import "core:log"
import "core:mem"
import "core:os"
import "core:strings"
import "core:testing"
import "core:fmt"

import sqlite "../"

alloc_size_list: map[rawptr]int

@(test)
invalid_table :: proc(t: ^testing.T) {
	db: ^sqlite.sqlite3

	file_name := "invalid_table.test.sqlite"
	defer rm_db(file_name)
	rc := sqlite.open(strings.unsafe_string_to_cstring(file_name), &db)
	defer sqlite.close(db)

	rc = sqlite.exec(db, "SELECT * FROM this_table_should_not_exist", nil, nil, nil)
	testing.expect(t, rc != .OK, "the table `this_table_should_not_exist` should not exist")
}

@(test)
valid_table :: proc(t: ^testing.T) {
	db: ^sqlite.sqlite3

	file_name := "valid_table.test.sqlite"
	defer rm_db(file_name)
	rc := sqlite.open(strings.unsafe_string_to_cstring(file_name), &db)
	defer sqlite.close(db)

	rc = sqlite.exec(db, "CREATE TABLE IF NOT EXISTS main (id INTEGER)", nil, nil, nil)
	testing.expectf(t, rc == .OK, "error(.%v) cannot create table `main`", rc)

	rc = sqlite.exec(db, "SELECT id FROM main", nil, nil, nil)
	testing.expectf(t, rc == .OK, "error(.%v) cannot fetch from table `main`", rc)
}

@(test)
prepared_stmts :: proc(t: ^testing.T) {
	db: ^sqlite.sqlite3
	stmt: ^sqlite.stmt
	to_be_prepared: cstring
	rows: i32

	file_name := "prepared_stmts.test.sqlite"
	defer rm_db(file_name)
	rc := sqlite.open(strings.unsafe_string_to_cstring(file_name), &db)
	defer sqlite.close(db)

	to_be_prepared =
	`CREATE TABLE IF NOT EXISTS "shows" (
		"id"	INTEGER NOT NULL UNIQUE,
		"episode"	INTEGER NOT NULL DEFAULT 1,
		"season"	INTEGER NOT NULL DEFAULT 1,
		"show_name"	TEXT NOT NULL,
		"watch_time"	TEXT,
		PRIMARY KEY("id" AUTOINCREMENT) ON CONFLICT ROLLBACK
	);`


	sqlite.prepare_v2(db, to_be_prepared, -1, &stmt, nil)
	sqlite.step(stmt)
	sqlite.finalize(stmt)

	to_be_prepared = `SELECT * FROM "shows"`
	sqlite.prepare_v2(db, to_be_prepared, -1, &stmt, nil)
	for rows = 0; sqlite.step(stmt) == .ROW; rows += 1 {}
	sqlite.finalize(stmt)


	to_be_prepared =
	"INSERT INTO shows (episode, season, show_name, watch_time) VALUES (?, ?, ?, ?)"
	sqlite.prepare_v2(db, to_be_prepared, -1, &stmt, nil)
	sqlite.bind_int(stmt, 1, 5)
	sqlite.bind_int(stmt, 2, 1)
	sqlite.bind_text(stmt, 3, "Psych", -1)
	sqlite.bind_text(stmt, 4, "2024-09-02T19:51:50.856Z", -1)
	sqlite.step(stmt)

	sqlite.reset(stmt)
	sqlite.bind_int(stmt, 1, 6)
	sqlite.bind_int(stmt, 2, 1)
	sqlite.bind_text(stmt, 3, "Psych", -1)
	sqlite.bind_text(stmt, 4, "2024-09-02T20:55:30.132Z", -1)
	sqlite.step(stmt)

	sqlite.finalize(stmt)

	to_be_prepared = `SELECT * FROM "shows"`
	sqlite.prepare_v2(db, to_be_prepared, -1, &stmt, nil)
	for rows = 0; sqlite.step(stmt) == .ROW; rows += 1 {}
	sqlite.finalize(stmt)

	testing.expectf(t, rows == 2, "expected 2; got %d", rows)
}

rm_db :: proc(file_name: string) {
	err := os.remove(file_name)

	when ODIN_OS == .Windows {
		if err == nil {} else if err != .FILE_NOT_FOUND {} else {
			log.errorf("(.%v): cannot delete file %s", err, file_name)
		}
	} else {
		if err != 0 {
			log.errorf("(.%v): cannot delete file %s", err, file_name)
		}
	}

}
