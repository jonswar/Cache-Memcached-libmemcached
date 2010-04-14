use strict;
use lib 't/lib';
use libmemcached_test;
use Test::More;

my $cache = libmemcached_test_create( {
    compress_threshold => 1_000
} );
plan(tests => 2);

libmemcached_isa_ok($cache);


{
    my $data = "1" x 5_000;
    $cache->set("foo", $data, 30);
    my $val = $cache->get("foo");
    is($val, $data, "simple value");
}
