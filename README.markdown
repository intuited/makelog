makelog
=======

A command logger implemented as a Makefile.

Running `make help` will give you this informative information:

    make launch command=COMMAND
        launches COMMAND, sending its output and error
          to files in the current session directory.
        If there is no current session, one is created.
        New sessions are named with a current RFC-3339 timestamp.
    
    make endsession
        Ends the current session by deleting the file `current`.
    
    EXAMPLE:
        $ make launch qjackctl
        $ make launch rosegarden
        $ make endsession
        $ find -mmin -2
        ./2010-08-04T02:41:17-0300/qjackctl.err
        ./2010-08-04T02:41:17-0300/qjackctl.out
        ./2010-08-04T02:41:17-0300/rosegarden.err
        ./2010-08-04T02:41:17-0300/rosegarden.out
    This will launch both qjackctl and rosegarden,
      sending their standard output and error to files
      in a directory named with an RFC-3339 timestamp
      of the time the first command was issued.
    The files are named e.g. `qjackctl.out` and `qjackctl.err`.
