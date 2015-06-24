package app;

use v5.012;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use Dancer::Session;
#use Dancer::Plugin::Auth::Facebook;

use MovieWorld::Schema;
use IMDB::Film;

my $dsn = 'dbi:ODBC:Driver={SQL Server};Server=BETSY-TOSHIBA\SQLEXPRESS;Database=MovieWorld;UID=movieworld;PWD=movies';

our $VERSION = '0.1';

get '/' => sub {
    return template 'index';
};

get '/profile' => require_login sub {
	return template 'account/profile';
};

get '/add-movie' => require_login sub {
	return template 'movie/add_movie';
};

get '/my-movies' => require_login sub {
	my $schema = MovieWorld::Schema->connect($dsn);
	my @artists = $schema->resultset('Movie')->all;

	my $res = '';
	foreach my $artist (@artists) {
		#$res = "$res" . $artist->{title} . "\n";
		return $artist->title;
	}

	return $res;
};

post '/add-movie' => require_login sub {
	my $film = new IMDB::Film(crit => params->{title});
	my $schema = MovieWorld::Schema->connect($dsn);

	my $doesExist = $schema->resultset('Movie')->search( { title => params->{title} })->next;
	unless ($doesExist) {
		my $movie = $schema->resultset('Movie')->new({ 
			id => $film->code(),
			title => params->{title}
		});
		$movie->insert;
	}
};

post '/movie' => sub {
	my $film = new IMDB::Film(crit => params->{movieName});

	return template 'movie/film', { 
		code => $film->code(),
		title => $film->title(),
		year => $film->year(),
		cover => $film->cover(),
		kind => $film->kind(),
		plot => $film->plot(),
		genres => (join ', ', @{$film->genres()}),
		storyline => $film->storyline(),
		duration => $film->duration(),
		country => (join ', ', @{$film->country()}),
		language => (join ', ', @{$film->language()}),
	};
};

get '/movie-image/:title' => sub {
	my $film = new IMDB::Film(crit => params->{title});

	content_type 'text/plain';
	return $film->cover();
};

get '/moviesearch' => sub {
	return template 'movie/movie_search'
};

get '/about' => sub { 
	return template 'general/about';
};

get '/register' => sub {
	return template 'account/register';
};

get '/logintest' => require_login sub {	
	my $user = logged_in_user;
	return "You're logged in!";
};

get '/logout' => sub {
	session->destroy;
	return template 'account/logged_out'
};

post '/login' => sub {
	my ($success, $realm) = authenticate_user(params->{username}, params->{password});
    if ($success) {
        session logged_in_user => params->{username};
        session logged_in_user_realm => $realm;
        
        return template 'index';
    } 
	return template 'account/login', { message => 'Login failed.', alert_class => 'danger' };
};

post '/register' => sub {
	my $schema = MovieWorld::Schema->connect($dsn);

	my $doesExist = $schema->resultset('User')->search( { username => params->{username} })->next;
	if ($doesExist) {
		return template 'account/register', { message => ' Username already exists.', alert_class => 'danger' };
	}
	if (params->{password} eq params->{confirm}) {
		my $user = $schema->resultset('User')->new({ 
			username => params->{username},
			password => params->{password}
		});

		$user->insert;
		return template 'account/login', { message => 'Account created. You can now log in.', alert_class => 'success' };
	}
	return template 'account/register', { message => 'Both passwords must match', alert_class => 'info' }
};
# auth_fb_init();
 
# hook before =>  sub {
#   #we don't want a redirect loop here.
#   return if request->path =~ m{/auth/facebook/callback};
#   if (not session('fb_user')) {
#      redirect auth_fb_authenticate_url;
#   }
# };
 
get '/login' => sub {
	return template 'account/login';
};

get '/login/denied' => sub {
	return template 'account/denied';
};

1;