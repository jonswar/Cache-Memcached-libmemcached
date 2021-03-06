use strict;
use lib 't/lib';
use libmemcached_test;
use Test::More;


my $cache = libmemcached_test_create( {
    namespace => "fooblabaz",
} );

plan(tests => 11);
libmemcached_isa_ok($cache);

{
    $cache->set("foo", "bar", 300);
    my $val = $cache->get("foo");
    is($val, "bar", "simple value");
}

{
    $cache->set("foo", { bar => 1 }, 300);
    my $val = $cache->get("foo");
    is_deeply($val, { bar => 1 }, "got complex values");
}

{
    ok( $cache->get("foo"),  "before delete returns ok");
    ok( $cache->delete("foo") );
    ok( ! $cache->get("foo"),  "delete works");
    ok( ! $cache->delete("foo") );
}

{
    ok( $cache->set("foo", 1), "prep for incr" );
    is( $cache->incr("foo"), 2, "incr returns 1 more than previous" );
    is( $cache->decr("foo"), 1, "decr returns 1 less than previous" );
}

SKIP: {
    if (Cache::Memcached::libmemcached::OPTIMIZE) {
        skip("OPTIMIZE flag is enabled", 1);
    }
    $cache = libmemcached_test_create( {
        compress_enable => 1,
        namespace => "fooblabaz",
    });

    my $master_key = 'dummy_master';
    my $key        = 'foo_with_master';
    $cache->set([ $master_key, $key ], 100);
    is( $cache->get([ $master_key, $key ]), 100, "get with master key" );
}
