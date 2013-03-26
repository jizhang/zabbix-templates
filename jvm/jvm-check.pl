#!/usr/bin/perl

use strict;
use Getopt::Long;
use Pod::Usage;
use IO::Socket::INET;

use constant COLLECTOR_UP => 1;
use constant COLLECTOR_DOWN => 0;

sub stats {
    my ($jvmport, $service_addr) = @_;
    my ($service_ip, $service_port) = split(/:/, $service_addr);

    my $client = IO::Socket::INET->new(
        PeerAddr => $service_ip,
        PeerPort => $service_port,
        Type => SOCK_STREAM
    ) || die "Unable to connect to server.\n";

    print $client "JVMPORT $jvmport\n";
    my $status = <$client>;
    chomp($status);
    if ($status != 'OK') {
        print COLLECTOR_DOWN;
        return 2;
    }

    close($client);

    print COLLECTOR_UP;
    return 0;
}

my $help = 0;
my $jvmport = 0;
my $service_addr = '127.0.0.1:10060';

GetOptions (
    'help|?' => \$help,
    'jvmport=i' => \$jvmport,
    'service-addr=s' => \$service_addr
) || pod2usage(2);
pod2usage(1) if $help || !$jvmport;

exit(stats($jvmport, $service_addr));

__END__

=head1 NAME

JVM Statistics

=head1 SYNOPSIS

jvm-check.pl [options]

 Options:
   -help         brief help message
   -jvmport      JVM port
   -service-addr service address "ip:port"

=cut
