#!/usr/bin/env perl

use strict;
use warnings;

use File::Temp          qw(tempdir);
use Cwd                 qw(getcwd);
use IPC::System::Simple qw(capturex systemx);

use OpenAI::API::Request::Chat;

my $MODEL       = 'gpt-4';    # Request access via https://openai.com/waitlist/gpt-4-api
my $MAX_TOKENS  = 4096;
my $TEMPERATURE = 0.1;

my $chat = OpenAI::API::Request::Chat->new(
    model       => $MODEL,
    max_tokens  => $MAX_TOKENS,
    temperature => $TEMPERATURE,
    messages    => messages(),
);

optional_output(
    qq{# Perl Code Assistant\n},
    qq{# Write your request. Example: "write a function to generate fibonacci numbers"\n},
    qq{# Remember to finish your message with ^D\n\n},
);

INPUT:
while (1) {
    optional_output("> ");
    my @input = <>;
    chomp @input;

    if ( !@input || $input[0] =~ /^(?:quit|exit|bye)$/i ) {
        last INPUT;
    }

    my $input = join( "\n", @input );

    my $res;

    CODEGEN:
    for ( 1 .. 3 ) {
        optional_output("# Generating...\n");
        eval {
            $res = $chat->send_message($input);
            1;
        } or do {
            my $error = $@;
            die $error->response->content;
        };

        optional_output("# Testing the script...");
        save_and_run("$res");
        my ( $prove_output, $error ) = save_and_run("$res");
        if ( !$error ) {
            optional_output("\n# It worked!!! \\o/\n\n");
            last CODEGEN;
        }

        $input = <<~"NEXT_PROMPT";
            I got the following output:

            ```
            $prove_output
            ```

            Can you you fix this error?
            Please generate the entire script again, with no dialogue.
            NEXT_PROMPT

        optional_output("$input\n\n");
    }

    print("$res\n");
}

sub optional_output {
    my @lines = @_;
    return if !-t STDOUT;

    print "$_" for @lines;
}

sub save_and_run {
    my ($bash_script) = @_;

    if ( $bash_script !~ /perl/ ) {
        die "Invalid script:\n\n$bash_script\n";
    }

    my $temp_dir    = tempdir( CLEANUP => 1 );
    my $current_dir = getcwd();

    # Execute the bash script in the temporary directory
    chdir $temp_dir;
    open( my $fh, '|-', 'bash' ) or die "Cannot open pipe to bash: $!";
    print $fh $bash_script;
    close($fh) or die "Cannot close pipe to bash: $!";

    # Run the prove command and capture the output
    my ( $prove_output, $error_code );
    eval {
        $prove_output = capturex( 'prove', '-lrv' );
        1;
    } or do {
        my $error = $@;
        warn "Test error: $error";
        $error_code = $error ? 1 : 0;
    };

    # Return to the original directory
    chdir $current_dir;

    return ( $prove_output, $error_code );
}

### PROMPT ENGINEERING ###

sub messages {
    return [
        {
            # System instructions
            role    => "system",
            content => <<~'INSTRUCTIONS',
            You are a code generator. You are not designed for conversation.
            You should only return only the source code, without additional dialogue.

            For example, if someone asks to write a module, you will return the 
            following code output:

            ```
            # 1. Generate the directories

            BASE_DIR=/tmp/MyModule

            mkdir -p $BASE_DIR/lib/
            mkdir -p $BASE_DIR/t/

            # 2. Generate the required test files

            cat > $BASE_DIR/t/test.t <<'EOF'
            # test source code
            EOF

            # 3. Generate the required code

            cat > $BASE_DIR/lib/Foo.pm <<'EOF'
            # requested source code
            EOF
            ```
            INSTRUCTIONS
        },
        {
            # Now, we will fake a conversation to make sure the LLM understands the instructions
            role    => "user",
            content => <<~'REQUEST',
                Generate a function that returns "Hello, world!"
                REQUEST
        },
        {
            # This is a simulated response, to exemplify how we want the output
            role    => "assistant",
            content => <<~'END_EXAMPLE',
            # 1. Generate the directories

            BASE_DIR=/tmp/Hello-World

            mkdir -p $BASE_DIR/lib/Hello
            mkdir -p $BASE_DIR/t/

            # 2. Generate the required test files

            cat > $BASE_DIR/t/00-load.t <<'EOF'
            #!perl
            use 5.006;
            use strict;
            use warnings;
            use Test::More;

            BEGIN {
                use_ok( 'Hello::World' ) || print "Bail out!\n";
            }

            diag( "Testing Hello::World $Hello::World::VERSION, Perl $], $^X" );

            done_testing();
            EOF

            cat > $BASE_DIR/t/hello_world.t <<'EOF'
            #!perl
            use 5.006;
            use strict;
            use warnings;
            use Test::More;

            use_ok('Hello::World');

            is( Hello::World::hello_world(), 'Hello, world!' );

            done_testing();
            EOF

            # 3. Generate the required modules

            cat > $BASE_DIR/lib/Hello/World.pm <<'EOF'
            package Hello::World;

            use 5.006;
            use strict;
            use warnings;

            our $VERSION = '0.01';

            sub hello_world {
                return "Hello, world!";
            }

            1;
            EOF
            END_EXAMPLE
        }
    ];
}

__END__

=head1 NAME

codegen-gpt4.pl - Perl code generator based on GPT-4

=head1 SYNOPSIS

    # interactive mode
    ./codegen-gpt4.pl

    # read prompt from a file
    ./codegen-gpt4.pl [filename]

=head1 DESCRIPTION

This Perl script is a command-line tool that interacts with the OpenAI
GPT-4 API to generate Perl code based on the user's input. Users can
enter their requests, and the script will communicate with the GPT-4
API to generate and test the Perl code.

=head1 USAGE

To run the script, use the following command:

    ./codegen-gpt4.pl

You will be prompted to enter your request. For example:

"write a function to generate fibonacci numbers"

To finish your message, press ^D (Control + D). The script will then
communicate with the GPT-4 API to generate the Perl code based on
your input.

To exit the script, type 'quit', 'exit', or 'bye' when prompted for input.

=head1 AUTHOR

Nelson Ferraz (L<@nferraz|https://twitter.com/nferraz>)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 by Nelson Ferraz

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
