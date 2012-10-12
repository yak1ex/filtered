use Test::More tests => 10;

use FindBin;
use lib "$FindBin::Bin";

package a;

BEGIN { ::use_ok('filtered', by => 'MyFilter', as => 'FilteredTest', on => 'FilterTest', 'call'); }

# Duplicated use should have no effect
BEGIN { ::use_ok('filtered', by => 'MyFilter', as => 'FilteredTest', on => 'FilterTest', 'call'); }

# Duplicated use should have no effect
BEGIN { ::use_ok('filtered', by => 'MyFilter', as => 'FilteredTest', 'FilterTest', 'call'); }

::is(call(), 'BARBARBAR');

package b;

# Different filter should be available
BEGIN { ::use_ok('filtered', by => 'MyFilter2', as => 'FilteredTest2', on => 'FilterTest', 'call'); }

::is(call(), 'BARFOO');

package c;

# Different target should be available
BEGIN { ::use_ok('filtered', by => 'MyFilter2', as => 'FilteredTest3', on => 'FilterTest2', 'call'); }

::is(FilteredTest3::call(), 'BARBAR');

package d;

# Different target should be available
BEGIN { ::use_ok('filtered', by => 'MyFilter2', 'FilterTest3', 'call'); }

::is(FilterTest3::call(), 'BARZOTZOT');
