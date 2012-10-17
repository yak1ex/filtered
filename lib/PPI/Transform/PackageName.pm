use strict;
use warnings;

package PPI::Transform::PackageName;

# VERSION

use base qw(PPI::Transform);

sub new
{
    my $self = shift;
    my $class = ref($self) || $self;
    my %arg = @_;
    return bless {
        _PKG => $arg{-package_name},
        _WORD => $arg{-word}
    }, $class;
}

sub document
{
    my ($self, $doc) = @_;
    $doc->prune('PPI::Token::Comment');
    my $words = $doc->find('PPI::Token::Word');
    for my $word (@$words) {
        if(defined $self->{_PKG} && $word->statement->class eq 'PPI::Statement::Package') {
            my $content = $word->content;
            $_ = $content;
            $self->{_PKG}->();
            $word->set_content($_) if $_ ne $content;    
        } elsif(defined $self->{_WORD}) {
            my $content = $word->content;
            $_ = $content;
            $self->{_WORD}->();
            $word->set_content($_) if $_ ne $content;    
        }
    }
    return 1;
}

1;
__END__
=pod

=head1 NAME

PPI::Transform::PackageName - Subclass of PPI::Transform specific for modifying package names

=head1 SYNOPSIS

  use PPI::Transform::PackageName;

  my $trans = PPI::Transform::PackageName->new(-package_name => sub { s/Test//g }, -word => sub { s/Test//g });
  $trans->file('Input.pm' => 'Output.pm');

=head1 DESCRIPTION

This module is a subclass of PPI::Transform specific for modifying package name.

=head1 OPTIONS

=over 4

=item I<-package_name>

Specify code reference called for modifying arguments of C<package> statements.
The code reference is called for each argument.
Original is passed as $_  and it is expected that $_ is modified.

=item I<-word>

Specify code reference called for modifying bare words other than arguments of C<package> statement.
The code reference is called for each bare word.
Original is passed as $_  and it is expected that $_ is modified.

=back

=head1 AUTHOR

Yasutaka ATARASHI <yakex@cpan.org>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
