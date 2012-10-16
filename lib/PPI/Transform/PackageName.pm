use strict;
use warnings;

package PPI::Transform::PackageName;

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
