Test the output of the man page:
  $ ono concrete --help=plain
  NAME
         ono-concrete - This is a doc for concrete command
  
  SYNOPSIS
         ono concrete [OPTION]… FILE
  
  ARGUMENTS
         FILE (required)
             Source file to analyze.
  
  OPTIONS
         --config=FILE
             Set a config for the game from .sexp file.
  
         --height=INT
             Define a height for --use-graphical-window option. Default value
             is 600px.
  
         --print-steps=INT
             The last steps to display.
  
         --seed=INT
             Set the seed for random number generation.
  
         --steps=INT
             Define the amount of steps the game will do. Negative values will
             be ignored.
  
         --use-graphical-window
             Create a graphical window for the game.
  
         --width=INT
             Define a width for --use-graphical-window option. Default value is
             800px.
  
  COMMON OPTIONS
         --color=WHEN (absent=auto)
             Colorize the output. WHEN must be one of auto, always or never.
  
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         -q, --quiet
             Be quiet. Takes over -v and --verbosity.
  
         -v, --verbose
             Increase verbosity. Repeatable, but more than twice does not bring
             more.
  
         --verbosity=LEVEL (absent=warning or ONO_VERBOSITY env)
             Be more or less verbose. LEVEL must be one of quiet, error,
             warning, info or debug. Takes over -v.
  
         --version
             Show version information.
  
  EXIT STATUS
         ono concrete exits with:
  
         0   on success.
  
         1   on conversion to integer error in Wasm code.
  
         2   on unreachable instruction in Wasm code.
  
         3   on division by zero in Wasm code.
  
         4   on integer overflow in Wasm code.
  
         5   on stack overflow in Wasm code.
  
         6   on out of bounds memory access in Wasm code.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  ENVIRONMENT
         These environment variables affect the execution of ono concrete:
  
         ONO_VERBOSITY
             See option --verbosity.
  
  SEE ALSO
         ono(1)
  























