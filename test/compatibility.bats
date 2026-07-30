#!/usr/bin/env bats

setup() {
	PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

@test "library runs in available POSIX-compatible shells" {
	tested=0
	for shell_path in /bin/sh /bin/dash /bin/bash /usr/local/bin/bash /bin/ksh; do
		[ -x "$shell_path" ] || continue
		tested=$((tested + 1))

		run "$shell_path" -c '
			. "$1"
			log4u_set_console_level DEBUG || exit 10
			[ "$(log4u_get_console_level)" = DEBUG ] || exit 11
			log4u_info compatibility
		' test-shell "$PROJECT_ROOT/log4u"

		[ "$status" -eq 0 ]
		[[ "$output" == *" INFO test-shell: compatibility" ]]
	done

	[ "$tested" -gt 0 ]
}
