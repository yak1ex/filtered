use Test::More tests => 12;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin";

BEGIN { use_ok('filtered', by => 'MyFilter', as => 'FilteredTest', on => 'FilterTest'); }

# Duplicated use should have no effect
BEGIN { use_ok('filtered', by => 'MyFilter', as => 'FilteredTest', on => 'FilterTest'); }

# Duplicated use should have no effect
BEGIN { use_ok('filtered', by => 'MyFilter', as => 'FilteredTest', 'FilterTest'); }

BEGIN { throws_ok { die $@ if ! defined eval "use filtered by => 'MyFilter', 'NotExistentFilterTest'"; } qr/Can't find .* in \@INC/, 'Not-existent module' }

BEGIN { throws_ok { die $@ if ! defined eval "use filtered by => 'NotExistentMyFilter', 'FilterTest'"; } qr/Can't load /, 'Not-existent filter' }

# Different filter should be available
BEGIN { use_ok('filtered', by => 'MyFilter2', as => 'FilteredTest2', on => 'FilterTest'); }

# Different target should be available
BEGIN { use_ok('filtered', by => 'MyFilter2', as => 'FilteredTest3', on => 'FilterTest2'); }

# Different target should be available
BEGIN { use_ok('filtered', by => 'MyFilter2', 'FilterTest3'); }

is(FilteredTest::call(), 'BARBARBAR');
is(FilteredTest2::call(), 'BARFOO');
is(FilteredTest3::call(), 'BARBAR');
is(FilterTest3::call(), 'BARZOTZOT');
