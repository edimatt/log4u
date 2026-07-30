#!/usr/bin/env bats

setup() {
	PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	cd "$BATS_TEST_TMPDIR"
	# shellcheck source=../log4u
	. "$PROJECT_ROOT/log4u"
}

write_config() {
	config_path=$1
	shift
	printf '%s\n' "$@" > "$config_path"
}

@test "defaults enable INFO console logging without initialization" {
	run log4u_info "ready"

	[ "$status" -eq 0 ]
	[[ "$output" == *" INFO "*"ready" ]]
	[ "$(log4u_get_console_level)" = INFO ]
}

@test "DEBUG is filtered by the default INFO threshold" {
	run log4u_debug "hidden"

	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "runtime setters control console and file levels independently" {
	log4u_set_console_level WARN
	log4u_set_file_level DEBUG

	[ "$(log4u_get_console_level)" = WARN ]
	[ "$(log4u_get_file_level)" = DEBUG ]
}

@test "invalid runtime levels return 2 and preserve state" {
	log4u_set_console_level WARN

	run log4u_set_console_level LOUD

	[ "$status" -eq 2 ]
	[[ "$output" == *"invalid console level"* ]]
	[ "$(log4u_get_console_level)" = WARN ]
}

@test "logging functions join all arguments safely" {
	run log4u_info "-n" "two  spaces" '100% \ * ? [abc]'

	[ "$status" -eq 0 ]
	[[ "$output" == *": -n two  spaces 100% \\ * ? [abc]" ]]
}

@test "warnings, errors, and failures use stderr" {
	log4u_warn "warning" >standard.out 2>standard.err
	log4u_error "error" >>standard.out 2>>standard.err
	log4u_fail "failure" >>standard.out 2>>standard.err

	[ ! -s standard.out ]
	grep -q " WARN .*warning" standard.err
	grep -q " ERROR .*error" standard.err
	grep -q " FAIL .*failure" standard.err
}

@test "log entries contain ISO timestamp, timezone, PID, level, and script" {
	run log4u_info "formatted"

	[ "$status" -eq 0 ]
	[[ "$output" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}[+-][0-9]{4}\ \[[0-9]+\]\ INFO\ .+:\ formatted$ ]]
}

@test "multiline messages preserve continuation lines" {
	run log4u_info $'first line\nsecond line'

	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[0]}" == *" INFO "*"first line" ]]
	[ "${lines[1]}" = "second line" ]
}

@test "valid configuration supports whitespace and paths with spaces" {
	write_config settings.conf \
		" # comment" \
		" LOG4U.CONSOLE " \
		" LOG4U.CONSOLE.LEVEL = ERROR " \
		" LOG4U.LOGFILE = application output.log, a " \
		" LOG4U.LOGFILE.LEVEL = DEBUG "

	log4u_init settings.conf
	log4u_debug "file only"

	[ "$(log4u_get_console_level)" = ERROR ]
	grep -q "DEBUG .*file only" "application output.log"
}

@test "duplicate configuration properties use the last value" {
	write_config settings.conf \
		"LOG4U.CONSOLE" \
		"LOG4U.CONSOLE.LEVEL=DEBUG" \
		"LOG4U.CONSOLE.LEVEL=ERROR"

	log4u_init settings.conf

	[ "$(log4u_get_console_level)" = ERROR ]
}

@test "invalid configuration is rejected atomically" {
	log4u_set_console_level WARN
	before=$(log4u_status)
	write_config invalid.conf \
		"LOG4U.CONSOLE" \
		"LOG4U.CONSOLE.LEVEL=LOUD"

	run log4u_init invalid.conf

	[ "$status" -eq 1 ]
	[[ "$output" == *"line 2: invalid console level"* ]]
	[ "$(log4u_status)" = "$before" ]
}

@test "unknown configuration properties are rejected" {
	write_config invalid.conf "LOG4U.UNKNOWN=value"

	run log4u_init invalid.conf

	[ "$status" -eq 1 ]
	[[ "$output" == *"unknown property"* ]]
}

@test "missing configuration is rejected without resetting defaults" {
	run log4u_init missing.conf

	[ "$status" -eq 1 ]
	[ "$(log4u_get_console_level)" = INFO ]
}

@test "append mode preserves existing logfile content" {
	printf '%s\n' "existing" >application.log
	write_config settings.conf \
		"LOG4U.LOGFILE=application.log,a" \
		"LOG4U.LOGFILE.LEVEL=INFO"

	log4u_init settings.conf
	log4u_info "new entry"

	[ "$(sed -n '1p' application.log)" = existing ]
	grep -q "INFO .*new entry" application.log
}

@test "delete mode removes existing logfile during initialization" {
	printf '%s\n' "existing" >application.log
	write_config settings.conf "LOG4U.LOGFILE=application.log,d"

	log4u_init settings.conf

	[ ! -e application.log ]
}

@test "console colors do not leak into file output" {
	write_config settings.conf \
		"LOG4U.CONSOLE" \
		"LOG4U.LOGCOLORS" \
		"LOG4U.LOGFILE=application.log,a"

	log4u_init settings.conf
	log4u_info "colored" >console.out

	grep -q $'\033\\[37m' console.out
	grep -q $'\033\\[0m' console.out
	! grep -q $'\033' application.log
}

@test "logging returns nonzero when a configured output cannot be written" {
	write_config settings.conf "LOG4U.LOGFILE=missing/application.log,a"
	log4u_init settings.conf

	run log4u_info "cannot write"

	[ "$status" -ne 0 ]
}

@test "reset restores documented defaults" {
	log4u_set_console_level FAIL
	log4u_set_file_level DEBUG

	log4u_reset

	[ "$(log4u_get_console_level)" = INFO ]
	[ "$(log4u_get_file_level)" = INFO ]
	run log4u_info "enabled"
	[ -n "$output" ]
}

@test "legacy public aliases remain compatible" {
	logSetLevel ERROR

	[ "$(logGetLevel)" = ERROR ]
	run logInfo "filtered"
	[ -z "$output" ]
	run logErr "visible"
	[[ "$output" == *" ERROR "*"visible" ]]
}
