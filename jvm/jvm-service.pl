#!/usr/bin/perl

use strict;
use Getopt::Long;
use Pod::Usage;
use IO::Socket::INET;

sub stats {
    my $jvmport = shift(@_);

    my @netstat = `netstat -nlpt`;
    my $pid = 0;
    foreach my $line (@netstat) {
        if ($line =~ /.*?:$jvmport\s.*?([0-9]+)\/java\s*$/) {
            $pid = $1;
            last;
        }
    }
    if (!$pid) {
        return 0;
    }

    my $result = '';

    my @jstat = `jstat -gc $pid`;
    $result .= kv_parse(@jstat);

    my @jstack = `jstack $pid`;
    my $threads = 0;
    my $threads_running = 0;
    for my $line (@jstack) {
        if (index($line, '"') != -1) {
            $threads += 1;
        }
        if (index($line, 'java.lang.Thread.State: RUNNABLE') != -1) {
            $threads_running += 1;
        }
    }
    $result .= "threads $threads\n";
    $result .= "threads_running $threads_running\n";

    my @ps = `ps -o pcpu,rss -p $pid`;
    $result .= kv_parse(@ps);

    return $result;

}

sub kv_parse {
    my @kv_data = @_;

    map { s/^\s+|\s+$// } @kv_data;
    my @kv_keys = split(/\s+/, $kv_data[0]);
    my @kv_vals = split(/\s+/, $kv_data[1]);

    my $result = '';
    for my $i (0 .. $#kv_keys) {
        $result .= "$kv_keys[$i] $kv_vals[$i]\n";
    }

    return $result;
}

my $help = 0;
my $port = 10060;

GetOptions ('help|?' => \$help, 'port=i' => \$port) || pod2usage(2);
pod2usage(1) if $help;

print "Bind to port $port.\n";

my $server = IO::Socket::INET->new(
    LocalPort => $port,
    Type => SOCK_STREAM,
    Reuse => 1,
    Listen => SOMAXCONN
) || die "Unable to create server.\n";

while (my $client = $server->accept()) {

    my $input = <$client>;
    chomp($input);

    if ($input =~ /^JVMPORT ([0-9]+)$/) {

        print "JVMPORT is $1.\n";

        if (my $result = stats($1)) {
            print $client "OK\n", $result, "\n";
            print "OK\n";
        } else {
            print $client "ERROR\n";
            print "ERROR\n";
        }

    } else {
        print "Invalid input '$input'.\n";
    }

} continue {
    close($client);
}

close($server);

__END__

=head1 NAME

JVM Statistics

=head1 SYNOPSIS

jvm-server.pl [options]

 Options:
   -help brief help message
   -port bind to tcp port

=cut
