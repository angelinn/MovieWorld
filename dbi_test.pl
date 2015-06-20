#!perl

use v5.012;
use strict;
use warnings;

use DBI;

my $username = 'movieworld';
my $password = 'movies';
my $ip = 'BETSY-TOSHIBA\SQLEXPRESS';
my $db = 'PerlTest';

my $dbh = DBI->connect("dbi:ODBC:Driver={SQL Server};Server=$ip;Database=$db;UID=$username;PWD=$password;");

my $res = $dbh->prepare('SELECT * FROM Student');
$res->execute();

while (my @row = $res->fetchrow_array) {
	say @row;
}