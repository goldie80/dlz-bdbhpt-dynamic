#!/usr/bin/perl -w
use strict;
use BerkeleyDB;

my $replId = 0;

# Change this to reflect the filename you're storing your BerkeleyDB data in
my $db_file = 'dnsdata.db';

my $flags =  DB_CREATE | DB_INIT_MPOOL;

my $zones = [qw/example.net example.com example.org another.example.com/];

my $dns_data = new BerkeleyDB::Hash
    -Filename  => $db_file,
    -Flags     => $flags,
    -Property  => DB_DUP | DB_DUPSORT,
    -Subname   => "dns_data"
    ||    die "Cannot create dns_data: $BerkeleyDB::Error";

foreach my $zone (@$zones) {
    if ($dns_data->db_put("$zone www", "$replId www 3600 A 127.0.0.1") != 0) {
        die "Cannot add record '$zone www' -> '$replId www 3600 A 0 127.0.0.1' to dns_data: $BerkeleyDB::Error";
    }
    if ($dns_data->db_put("$zone \@", "$replId \@ 3600 SOA ns1.$zone root.$zone 604800 86400 2419200 10800") != 0) {
        die "Cannot add record '$zone \@' -> '$replId \@ 3600 SOA ns1.$zone root.$zone 604800 86400 2419200 10800' to dns_data: $BerkeleyDB::Error";
    }
    $replId++;
}

$dns_data->db_close();

my $dns_xfr = new BerkeleyDB::Hash
    -Filename  => $db_file,
    -Flags     => $flags,
    -Property  => DB_DUP | DB_DUPSORT,
    -Subname   => "dns_xfr"
    or die "Cannot create dns_xfr: $BerkeleyDB::Error";

foreach my $zone (@$zones) {
    if ($dns_xfr->db_put("$zone/www", "1") != 0) {
        die "Cannot add record to dns_xfr: $BerkeleyDB::Error";
    }
}

$dns_xfr->db_close();

my $dns_client = new BerkeleyDB::Hash
    -Filename  => $db_file,
    -Flags     => $flags,
    -Property  => DB_DUP | DB_DUPSORT,
    -Subname   => "dns_client"
    or die "Cannot create dns_client: $BerkeleyDB::Error";

foreach my $zone (@$zones) {
    if ($dns_client->db_put("$zone", "127.0.0.1") != 0) {
        die "Cannot add record to dns_client: $BerkeleyDB::Error";
    }
}

$dns_client->db_close();

my $dns_zone = new BerkeleyDB::Btree
    -Filename  => $db_file,
    -Flags     => $flags,
    -Property  => 0,
    -Subname   => "dns_zone"
    or die "Cannot create dns_zone: $BerkeleyDB::Error";

foreach my $zone (@$zones) {
    my $reversed_zone = reverse($zone);
    if ($dns_zone->db_put($reversed_zone, "1") != 0) {
        die "Cannot add record to dns_zone: $BerkeleyDB::Error";
    }
};

$dns_zone->db_close();

exit 0;
