use Test::More tests => 11;

use FindBin;
use lib $FindBin::Bin;

$ENV{FILTERED_TEST_TYPE} = 2; # use_ppi => 0
do 'import.pl';
