package MyFilter3;

use Filter::Simple;

FILTER sub {
    s/FOO/ZOT/g;
};

1;
