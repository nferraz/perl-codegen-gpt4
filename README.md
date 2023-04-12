# NAME

codegen-gpt4.pl - Perl code generator based on GPT-4

# SYNOPSIS

    # interactive mode
    ./codegen-gpt4.pl

    # read prompt from a file
    ./codegen-gpt4.pl [filename]

# DESCRIPTION

This Perl script is a command-line tool that interacts with the OpenAI
GPT-4 API to generate Perl code based on the user's input. Users can
enter their requests, and the script will communicate with the GPT-4
API to generate and test the Perl code.

# USAGE

To run the script, use the following command:

    ./codegen-gpt4.pl

You will be prompted to enter your request. For example:

"write a function to generate fibonacci numbers"

To finish your message, press ^D (Control + D). The script will then
communicate with the GPT-4 API to generate the Perl code based on
your input.

To exit the script, type 'quit', 'exit', or 'bye' when prompted for input.

# AUTHOR

Nelson Ferraz ([@nferraz](https://twitter.com/nferraz))

# COPYRIGHT AND LICENSE

Copyright (C) 2023 by Nelson Ferraz

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
