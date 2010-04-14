use strict;
use lib "t/lib";
use libmemcached_test;
use Test::More tests => 4;

$ENV{LIBMEMCACHED_SHARE_BETWEEN_NAMESPACES} = 1;

# cache 0 and 1, and cache 2 and 3, should have the same cml
# (Cache::Memcached::libmemcached) object underneath
#
my @caches = map { libmemcached_test_create($_) } (
    { namespace => 'foo' },
    { namespace => 'bar' },
    { namespace => 'baz', compress_threshold => 999 },
    { namespace => 'blarg', compress_threshold => 999 }
);

# explicitly create a cache with the same cml as #2
$caches[4] =
  libmemcached_test_create( { cml_object => $caches[2]->cml_object } );

is( $caches[0]->cml_object, $caches[1]->cml_object );
is( $caches[2]->cml_object, $caches[3]->cml_object );
is( $caches[2]->cml_object, $caches[4]->cml_object );
isnt( $caches[0]->cml_object, $caches[2]->cml_object );
