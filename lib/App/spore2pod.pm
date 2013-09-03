package App::spore2pod;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use base 'App::Cmd::Simple';

use JSON 2;

sub opt_spec {
    return (
        [ "doc_link_text|t=s", "Text to use for doc links" ],
        [ "spore_spec|f=s",    "Path to Spore spec to generate POD from " ] );
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;
    if ( !exists $opt->{spore_spec} && @$args ) {
        $opt->{spore_spec} = $args->[0];
    }
    $self->usage_error("Must specify path to readable spore spec!")
        unless -e $opt->spore_spec;
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    my $documentation_link_text
        = $opt->doc_link_text
        ? $opt->doc_link_text
        : 'Expanded documentation for this method is available.';

    my $spec;
    {
        local $/ = undef;
        open my $fh, '<', $opt->spore_spec
            or die "Couldn't open $opt->{spore_spec} for reading: $!";
        binmode FILE;
        my $spec_string = <$fh>;
        close $fh;
        $spec = decode_json($spec_string);
    }
    for my $method ( sort keys %{ $spec->{methods} } ) {
        my $method_data = $spec->{methods}{$method};
        print "=head2 $method\n\n";
        print "$method_data->{description}\n\n"
            if exists $method_data->{description};
        if ( $method_data->{required_params} ) {
            print "Required arguments: "
                . join( ', ',
                map {"C<$_>"} @{ $method_data->{required_params} } )
                . "\n\n";
        }
        if ( $method_data->{optional_params} ) {
            print "Optional arguments: "
                . join( ', ',
                map {"C<$_>"} @{ $method_data->{optional_params} } )
                . "\n\n";
        }
        if ( exists $method_data->{documentation} ) {
            print
                "L<$documentation_link_text|$method_data->{documentation}>\n\n";
        }

    }

}

1;
__END__

=encoding utf-8

=head1 NAME

App::spore2pod - Blah blah blah

=head1 SYNOPSIS

  use App::spore2pod;

=head1 DESCRIPTION

App::spore2pod is

=head1 AUTHOR

Mike Greb E<lt>michael@thegrebs.comE<gt>

=head1 COPYRIGHT

Copyright 2013- Mike Greb

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
