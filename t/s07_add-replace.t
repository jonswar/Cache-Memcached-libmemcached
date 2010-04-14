$ENV{LIBMEMCACHED_SHARE_BETWEEN_NAMESPACES} = 1;
(my $script = $0) =~ s/s(\d+)_/$1_/;
require $script;
