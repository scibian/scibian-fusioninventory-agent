package FusionInventory::Agent::Task::Inventory::Generic::Puppet;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use JSON;

my $seen;

sub isEnabled {
    return
        canRun('puppet');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        logger  => $logger,
        command => 'puppet agent --genconfig'
    );
    my $puppet_certname;

    if ($handle) {
        while (my $line = <$handle>) {
            next unless $line =~ /^[\s#]*certname\s*=\s*(\S+)\s*$/;
            $puppet_certname = $1;
            last;
        }
        close $handle;
    }
    return unless $puppet_certname;

    return unless (-r '/var/lib/puppet/client_data/catalog/'.$puppet_certname.'.json');
    $handle = getFileHandle(
        logger  => $logger,
        file => '/var/lib/puppet/client_data/catalog/'.$puppet_certname.'.json'
    );
    if ($handle) {
        my $perl_scalar = decode_json( <$handle> );
        my $version = $perl_scalar->{data}->{version};
            $inventory->setHardware({
                WINPRODKEY => $version
            });
        close $handle;
    }
}

1;
