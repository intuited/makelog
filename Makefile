# TODO: escape special characters in the command name
#         to form the output/error filenames.
#       It's particularly important to escape [\"],
#         since these may need to be used in actual commands.
#       An alternative to this approach
#         is to save the command in a separate file.
# TODO: enumerate commands which are run multiple times during the same session
# TODO: provide a way to set the session name
#         (as opposed to the session set name)
# TODO: see how practical it is to run this with a #!
# TODO: see if positional parameters can be passed to the make command
SHELL=/bin/bash

help:
	@echo \
	$$'make launch [name=NAME] command=COMMAND\n'\
	$$'    launches COMMAND, sending its output and error\n'\
	$$'      to files in the current NAME/session directory.\n'\
	$$'    If there is no current session for that NAME, one is created.\n'\
	$$'    New sessions are named with a current RFC-3339 timestamp.\n'\
	$$'    NAME defaults to \'default\'.\n'\
	$$'\n'\
	$$'make endsession\n'\
	$$'    Ends the current session by deleting the session file.\n'\
	$$'\n'\
	$$'EXAMPLE:\n'\
	$$'    $$ make name=rosegarden launch qjackctl\n'\
	$$'    $$ make name=rosegarden launch rosegarden\n'\
	$$'    $$ make name=rosegarden endsession\n'\
	$$'    $$ find -mmin -2\n'\
	$$'    ./rosegarden/2010-08-04T02:41:17-0300/qjackctl.err\n'\
	$$'    ./rosegarden/2010-08-04T02:41:17-0300/qjackctl.out\n'\
	$$'    ./rosegarden/2010-08-04T02:41:17-0300/rosegarden.err\n'\
	$$'    ./rosegarden/2010-08-04T02:41:17-0300/rosegarden.out\n'\
	$$'This will launch both qjackctl and rosegarden,\n'\
	$$'  sending their standard output and error to files\n'\
	$$'  in a directory named with an RFC-3339 timestamp\n'\
	$$'  of the time the first command was issued.\n'\
	$$'The files are named e.g. `qjackctl.out` and `qjackctl.err`.'

# timestamp used to initialize the session file
now := $(shell date --rfc-3339=s | tr \  T)

# $(name) is an identifier used for this set of sessions
# The sessions are placed in a subdirectory of that name.
name ?= default
$(name):
	mkdir -p $(name)


# The $(SESSION_FILE) holds the name of the $(session_dir).
SESSION_FILE := $(name)/.makelog_session_default
$(SESSION_FILE): $(name)
	echo "$(now)" > "$@"


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
session_dir = $(name)/$(shell cat $(SESSION_FILE))
session_dir: $(SESSION_FILE)
	mkdir -p "$(session_dir)"


# launch the specified $(command).
launch: session_dir
	$(command) \
	  >"$(session_dir)/$(command).out" \
	  2>"$(session_dir)/$(command).err" &

endsession:
	rm $(SESSION_FILE)
