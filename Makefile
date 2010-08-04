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
	$$'    Ends the current session by deleting the session file.\n'\
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


# timestamp used to initialize the session file
now := $(shell date --rfc-3339=s | tr \  T)

# These commands are meant to be run
#   by being included from a subdirectory's Makefile.

# The $(SESSION_FILE) holds the name of the $(session_dir).
SESSION_FILE := .makelog_session_default

$(SESSION_FILE):
	echo "$(now)" > "$(SESSION_FILE)"


# At this point we need to create the session directory.
# Ideally we would only attempt to create it if necessary.
# However, its name depends on the contents of the SESSION_FILE.
# This means that we can't make it a target
#   until after the $(SESSION_FILE) target has been made.
# Since making always comes after target parsing,
#   we can't do this without initiating a second expansion.
# I'm not totally sure that even that is possible,
#   and it seems pretty complex and crufty.
# So instead we just always try to create it.
# This works in a kludgy manner, by defining a target and a variable
#   which just happen to have the same name,
#   and storing a lazy evaluation of the file contents in the variable.
.PHONY: session_dir
session_dir = $(shell cat $(SESSION_FILE))
session_dir: $(SESSION_FILE)
	mkdir -p "$(session_dir)"


# launch the specified $(command).
launch: session_dir
	$(command) \
	  >"$(session_dir)/$(command).out" \
	  2>"$(session_dir)/$(command).err" &

endsession:
	rm $(SESSION_FILE)
