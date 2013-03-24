#!/usr/bin/perl

use strict;
use Getopt::Long;
use Pod::Usage;
use IO::Socket::INET;

sub stats {
    my $jvmport = shift(@_);
    return "hoho" . $jvmport;
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

jvmstat.sh [options]

 Options:
   -help brief help message
   -port bind to tcp port

=cut
