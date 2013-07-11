# NAME

Test::UsedModules - Detects needless modules which are being used in your module



# VERSION

This document describes Test::UsedModules version 0.02



# SYNOPSIS

    # check all of modules that are listed in MANIFEST
    use Test::More;
    use Test::UsedModules;
    all_used_modules_ok();
    done_testing;

    # you can also specify individual file
    use Test::More;
    use Test::UsedModules;
    used_modules_ok('/path/to/your/module_or_script');
    done_testing;



# DESCRIPTION

Test::UsedModules finds needless modules which are being used in your module to clean up the source code.



# METHODS

- all\_used\_modules\_ok

    This is a test function which finds needless used modules from modules that are listed in MANIFEST file.

- used\_modules\_ok

    This is a test function which finds needless used modules from specified source code.
    This function requires an argument which is the path to source file.

# DEPENDENCIES

- PPI (version 1.215 or later)
- Test::Builder::Module (version 0.98 or later)



# LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.



# AUTHOR

moznion <moznion@gmail.com>
