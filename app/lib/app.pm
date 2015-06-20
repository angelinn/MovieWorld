package app;

use v5.012;
use strict;
use warnings;

use Dancer ':syntax';
#use Dancer::Plugin::Auth::Facebook;
use IMDB::Film;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

post '/movie' => sub {
	my $film = new IMDB::Film(crit => params->{movieName});
	debug "Name of the movie " . params->{movieName};

	template 'movie/film', { 
		code => $film->code(),
		title => $film->title(),
		year => $film->year(),
		cover => $film->cover(),
		kind => $film->kind(),
		plot => $film->plot(),
		genres => \$film->genres(),
		storyline => $film->storyline(),
		duration => $film->duration(),
		#country => @{ $film->country() },
		#language => @{ $film->language() },
		#awards => @{ $film->awards()},

	};
};

get '/alt' => sub {
	template 'movie/movie_alt';
};

get '/login' => sub {
	template 'account/login';
};

get '/register' => sub {
	template 'account/register';
};

# auth_fb_init();
 
# hook before =>  sub {
#   #we don't want a redirect loop here.
#   return if request->path =~ m{/auth/facebook/callback};
#   if (not session('fb_user')) {
#      redirect auth_fb_authenticate_url;
#   }
# };
 
 
get '/fail' => sub { "FAIL" };

true;