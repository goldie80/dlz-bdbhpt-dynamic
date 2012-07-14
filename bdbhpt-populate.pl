#!/usr/bin/perl -w
################################################################################
#####   Perl libraries we need for this script
################################################################################

use strict;
use BerkeleyDB;
################################################################################
#####   Declare Global Variables
################################################################################

my $cacheDnsData = "";
my $cacheDnsZone = "";
my $cachefilesth = "";
my $connectCount = 0;
my $dnsClient = "";
my $dnsData = "";
my $dnsXfr = "";
my $dnsZone = "";
my @dnsZoneSplit = "";
my $newCacheHost = "";
my $hostCount = 0;
my $replId = 0;                                 #Initialize the replication ID
my $zoneRow = "";

# Change this to reflect the filename you're storing your BerkeleyDB data in
my $db_home = '/var/cache/bind/dlz';
my $db_file = 'dnsdata.db';
my $db_env = new BerkeleyDB::Env
    -Home => $db_home,
    -Flags => DB_CREATE | DB_INIT_MPOOL;

################################################################################
#####   File Creation
################################################################################

# unlink $db_file;

################################################################################
#####   Declare Subroutines
################################################################################

tie my %cacheDnsData, 'BerkeleyDB::Hash',
    -Env            => $db_env,
    -Property       => DB_DUP | DB_DUPSORT,
    -Subname        => "dns_data"
    or die "Cannot create dns_data: $BerkeleyDB::Error";

tie my %cacheDnsXfr, 'BerkeleyDB::Hash',
    -Env            => $db_env,
    -Property       => DB_DUP | DB_DUPSORT,
    -Subname        => "dns_xfr"
    or die "Cannot create dns_xfr: $BerkeleyDB::Error";

tie my %cacheDnsClient, 'BerkeleyDB::Hash',
    -Filename       => $db_env,
    -Property       => DB_DUP | DB_DUPSORT,
    -Subname        => "dns_client"
    or die "Cannot create dns_client: $BerkeleyDB::Error";

tie my %cacheDnsZone, 'BerkeleyDB::Btree',
    -Env            => $db_env,
    -Property       => 0,
    -Subname        => "dns_zone"
    or die "Cannot create dns_zone: $BerkeleyDB::Error";


my $zones = [qw/example.net example.com example.org another.example.com/];

#####   Generate data for the dns_data file
foreach my $zone (@$zones) {
    $cacheDnsData{"$zone www"} = "$replId www 3600 A 0 127.0.0.1";
    $replId++;
    
    #####   Generate data for the dns_zone file
    my $reversed_zone = reverse($zone);
    $cacheDnsZone{$reversed_zone} = "";
};

foreach my $zone (@$zones) {
    $cacheDnsXfr{"$zone/www"} = "";
};

foreach my $zone (@$zones) {
    $cacheDnsClient{"$zone"} = "127.0.0.1";
};
