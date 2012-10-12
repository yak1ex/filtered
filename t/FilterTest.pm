package FilterTest;

use strict;

require Exporter;
our (@ISA) = qw(Exporter);
our (@EXPORT_OK) = qw(call);

sub call
{
    return 'FOOFOOFOO';
}

1;
