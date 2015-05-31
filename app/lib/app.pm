package app;

use v5.012;
use strict;
use warnings;

use Dancer ':syntax';
use IMDB::Film;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

post '/movie' => sub {
	my $film = new IMDB::Film(crit => params->{movieName});
	template 'film', { code => $film->code() };
};

true;