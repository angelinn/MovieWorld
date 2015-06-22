#!perl

use v5.012;
use strict;
use warnings;

use IMDB::Film;

$ARGV[0] 
	or die 'ARGV not specified';

my $film = new IMDB::Film(crit => $ARGV[0]);

my %hash = (
	code => $film->code(),
	kind => $film->kind(),
	plot => $film->plot(),
	genres => $film->genres(),
	storyline => $film->storyline(),
	duration => $film->duration(),
	country => $film->country(),
	language => $film->language(),
	awards => $film->awards(),
);

say 'Code ' . $hash{'code'};
say 'Kind ' . $hash{'kind'};
say 'Plot ' . $hash{'plot'};
#say 'Genres ' . (join ' , ', $hash{'genres'});
say @{ $hash{'genres'} };
say 'Storyline ' . $hash{'storyline'};
say 'Duration ' . $hash{'duration'};
say 'Country ' . join ' ', @{$hash{'country'}};
say 'Language ' . $hash{'language'};
say 'Awards ' . $hash{'awards'};
