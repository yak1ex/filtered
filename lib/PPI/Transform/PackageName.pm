use strict;
use warnings;

package PPI::Transform::PackageName;

# ABSTRACT: Subclass of PPI::Transform specific for modifying package names
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

=head1 SYNOPSIS

  use PPI::Transform::PackageName;

  my $trans = PPI::Transform::PackageName->new(-package_name => sub { s/Test//g }, -word => sub { s/Test//g });
  $trans->file('Input.pm' => 'Output.pm');

=head1 DESCRIPTION

This module is a subclass of PPI::Transform specific for modifying package name.

=option I<-package_name>

Specify code reference called for modifying arguments of C<package> statements.
The code reference is called for each argument.
Original is passed as $_  and it is expected that $_ is modified.

=option I<-word>

Specify code reference called for modifying bare words other than arguments of C<package> statement.
The code reference is called for each bare word.
Original is passed as $_  and it is expected that $_ is modified.

=cut
