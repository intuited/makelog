# TODO: provide a $(name) variable that defaults to `default`
#         This will allow the subdirectory to be specified.
#         The session directories will then be created under the `name` subdir.
# TODO: escape special characters in the command name
#         to form the output/error filenames.
#       It's particularly important to escape [\"],
#         since these may need to be used in actual commands.
#       An alternative to this approach
#         is to save the command in a separate file.
# TODO: enumerate commands which are run multiple times during the same session
SHELL=/bin/bash

help:
	@echo \
	$$'make launch command=COMMAND\n'\
	$$'    launches COMMAND, sending its output and error\n'\
	$$'      to files in the current session directory.\n'\
	$$'    If there is no current session, one is created.\n'\
	$$'    New sessions are named with a current RFC-3339 timestamp.\n'\
	$$'\n'\
	$$'make endsession\n'\
	$$'    Ends the current session by deleting the file `current`.\n'\
	$$'\n'\
	$$'EXAMPLE:\n'\
	$$'    $$ make launch qjackctl\n'\
	$$'    $$ make launch rosegarden\n'\
	$$'    $$ make endsession\n'\
	$$'    $$ find -mmin -2\n'\
	$$'    ./2010-08-04T02:41:17-0300/qjackctl.err\n'\
	$$'    ./2010-08-04T02:41:17-0300/qjackctl.out\n'\
	$$'    ./2010-08-04T02:41:17-0300/rosegarden.err\n'\
	$$'    ./2010-08-04T02:41:17-0300/rosegarden.out\n'\
	$$'This will launch both qjackctl and rosegarden,\n'\
	$$'  sending their standard output and error to files\n'\
	$$'  in a directory named with an RFC-3339 timestamp\n'\
	$$'  of the time the first command was issued.\n'\
	$$'The files are named e.g. `qjackctl.out` and `qjackctl.err`.'


# timestamp used if there is no current file.
now := $(shell date --rfc-3339=s | tr \  T)

current = $(shell cat current)

# Meant to be run by being included from a subdirectory's Makefile.

current:
	echo "$(now)" > current
	mkdir "$(now)"

# launch the specified $(command).
launch: current
	$(command) >"$(current)/$(command).out" 2>"$(current)/$(command).err" &

endsession:
	rm current
