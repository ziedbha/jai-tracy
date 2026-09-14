// This file is for handling command-line options passed
// by the metaprogram.

// There are two hooks that we supply to do this. One
// handles individual options, and one logs a help string.

init :: (p: *Metaprogram_Plugin, options: [] string) -> bool {
    my := cast(*My_Plugin) p;
    success := true;

    cursor := 0;
    while cursor < options.count {
        s := options[cursor];
        if s == {
          case "-min_size";
            if cursor >= options.count-1 {
                log_error("Command line: Missing argument to -min_size.\n");
                success = false;
                break;
            }

            arg := options[cursor+1];
            result, success, remainder := string_to_int(arg);
            if !success {
                log_error("[Tracy] Command line: Argument to -min_size was expected to be an integer, but we got '%'.\n", arg);
                success = false;
                break;
            }

            if eat_spaces(remainder) {
                log_error("[Tracy] Command line: Found junk at the end of the argument to -min_size '%'.\n", remainder);
                success = false;
                break;
            }

            my.min_size = result;
            cursor += 2;

          case "-modules";
            my.instrument_modules = true;
            cursor += 1;

          case "-no_instrument";
            my.instrument = false;
            cursor += 1;

          case;
            log_error("Command line for plugin Tracy: Unknown argument '%'\n", s);
            success = false;
            break;
        }
    }

    return success;
}


log_help :: (p: *Metaprogram_Plugin) {
    log(HELP_STRING, MINIMUM_SIZE_DEFAULT);
}

HELP_STRING :: #string DONE
-min_size n        Instrument only procedures that are at least 'n' expressions large.
                   Use this to skip instrumenting small procedures, reducing overhead,
                   while still instrumenting major program locations.
                   The default is %1.

-modules           Instrument modules, as well as the main program.
DONE
