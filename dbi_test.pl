#!perl

use v5.012;
use strict;
use warnings;

use DBI;

my $username = 'movieworld';
my $password = 'movies';
my $ip = 'BETSY-TOSHIBA\SQLEXPRESS';
my $db = 'MovieWorld';

# my $dbh = DBI->connect("dbi:ODBC:Driver={SQL Server};Server=$ip;Database=$db;UID=$username;PWD=$password;");

# my $res = $dbh->prepare('SELECT * FROM users');
# $res->execute();

# while (my @row = $res->fetchrow_array) {
# 	say join ' ', @row;
# }

use MovieWorld::Schema;
my $dbs = "dbi:ODBC:Driver={SQL Server};Server=BETSY-TOSHIBA\\SQLEXPRESS;Database=MovieWorld;UID=movieworld;PWD=movies";
my $schema = MovieWorld::Schema->connect($dbs);
my @users = $schema->resultset('User')->all;

for my $user (@users){
	say $user->username . ' ' . $user->id;
}

