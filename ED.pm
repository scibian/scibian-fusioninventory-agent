package FusionInventory::Agent::Task::Inventory::Generic::ED;

use strict;
use warnings;
use JSON qw();

use FusionInventory::Agent::Tools;

my $logfile = '/var/log/edc-users.log';

sub isEnabled {
    return canRead($logfile);
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my %output_comment;

    my $handle = getFileHandle(
        logger => $logger,
        file   => $logfile
    );

    my %users;
    if ($handle) {
        while (my $line = <$handle>) {
            chomp $line;
            next unless $line =~ /\s(\S+)$/;
            $users{$1} = 1;
        }
        close $handle;
    }
    $output_comment{'ed users'} = [ keys %users ];

    $inventory->setHardware({ DESCRIPTION => JSON::encode_json(\%output_comment) });

}

1;
