use Test::More tests => 24;

use FindBin;
use lib $FindBin::Bin;

$ENV{FILTERED_TEST_TYPE} = 0; # no use_ppi option
do 'filtered_after_orig.pl';
