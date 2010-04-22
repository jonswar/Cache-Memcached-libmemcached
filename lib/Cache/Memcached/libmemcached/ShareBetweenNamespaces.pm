package Cache::Memcached::libmemcached::ShareBetweenNamespaces;
use Data::Dumper;
use strict;
use warnings;

my %cml_objects;

sub new {
    my ( $class, $params ) = @_;
    delete( $params->{share_between_namespaces} );
    my $namespace = delete( $params->{namespace} ) || '';
    my $cml_object = delete( $params->{cml_object} );

    if ( !$cml_object ) {
        my $cml_class = delete( $params->{cml_class} )
          || 'Cache::Memcached::libmemcached';

        my $cml_object_key = _dump_one_line( [ $class, $cml_class, $params ] );
        if ( !( $cml_objects{$cml_object_key} ) ) {
            $cml_objects{$cml_object_key} = $cml_class->new($params);
        }
        $cml_object = $cml_objects{$cml_object_key};
    }
    my $self = bless {
        cml_object => $cml_object,
        namespace  => $namespace
    }, $class;
    return $self;
}

sub cml_object { return $_[0]->{cml_object} }

# Create canonical string representation of data structure. Used to
# canonicalize parameters for memoization above.
#
sub _dump_one_line {
    my ($value) = @_;

    local $Data::Dumper::Indent    = 0;
    local $Data::Dumper::Sortkeys  = 1;
    local $Data::Dumper::Quotekeys = 0;
    local $Data::Dumper::Terse     = 1;
    return Dumper($value);
}

# Delegate all method calls to the cml object, switching namespace first
#
sub AUTOLOAD {
    my $self = shift;
    my ($method) = ( our $AUTOLOAD =~ /([^:]+)$/ );
    return if $method eq 'DESTROY';
    my $cml_object = $self->{cml_object};
    local $cml_object->{namespace} = $self->{namespace};
    return $cml_object->$method(@_);
}

1;
