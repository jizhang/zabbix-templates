#!/usr/bin/perl

use strict;
use Getopt::Long;
use Pod::Usage;
use IO::Socket::INET;

use constant COLLECTOR_UP => 1;
use constant COLLECTOR_DOWN => 0;

sub stats {
    my ($host, $jvmport, $service_addr, $zabbix_bin) = @_;
    my ($service_ip, $service_port) = split(/:/, $service_addr);

    my $client = IO::Socket::INET->new(
        PeerAddr => $service_ip,
        PeerPort => $service_port,
        Type => SOCK_STREAM
    ) || die "Unable to connect to server.\n";

    print $client "JVMPORT $jvmport\n";
    my $status = <$client>;
    chomp($status);
    if ($status ne 'OK') {
        print COLLECTOR_DOWN;
        return 2;
    }

    open my $fd, "| $zabbix_bin -s \"$host\" -i- >/dev/null 2>&1";

    while (<$client>) {
        chomp;
        my ($key, $value) = split /\s+/;
        if (!$key) {
            next;
        }
        $key = lc $key;
        $key =~ s/%/p/g;
        print $fd "- jvm.$key $value\n";
    }

    close($fd);
    close($client);

    print COLLECTOR_UP;
    return 0;
}

my $help = 0;
my $host = '';
my $jvmport = 0;
my $service_addr = '127.0.0.1:10060';
my $zabbix_sender = '/usr/local/zabbix-agent-ops/bin/zabbix_sender';
my $zabbix_conf = '/usr/local/zabbix-agent-ops/etc/zabbix_agentd.conf';

GetOptions (
    'help|?' => \$help,
    'host=s' => \$host,
    'jvmport=i' => \$jvmport,
    'service-addr=s' => \$service_addr,
    'zabbix-sender=s' => \$zabbix_sender,
    'zabbix-conf=s' => \$zabbix_conf
) || pod2usage(2);
pod2usage(1) if $help || !$jvmport || !$host;

exit(stats($host, $jvmport, $service_addr, "$zabbix_sender -c \"$zabbix_conf\""));

__END__

=head1 NAME

JVM Statistics

=head1 SYNOPSIS

jvm-check.pl [options]

 Options:
   -help          brief help message
   -host          hostname recognized by zabbix server
   -jvmport       JVM port
   -service-addr  service address "ip:port"
   -zabbix-sender path to zabbix_sender binary
   -zabbix-conf   path to zabbix_agentd.conf

=cut
