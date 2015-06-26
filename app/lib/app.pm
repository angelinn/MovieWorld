package app;

use v5.012;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use Dancer::Session;

use MovieWorld::Schema;
use IMDB::Film;

my $dsn = 'dbi:ODBC:Driver={SQL Server};Server=BETSY-TOSHIBA\SQLEXPRESS;Database=MovieWorld;UID=movieworld;PWD=movies';

our $VERSION = '0.1';

### GENERAL CONTROLLER 

get '/' => sub {
	my $schema = MovieWorld::Schema->connect($dsn);
	my @latest = $schema->resultset('UserReview')->search(undef, { order_by => { -desc => 'review_id'}, rows => 4 });
	my %viewbag;

	map { 
		$viewbag{$_->review_id} =  { 
			review => $_->review, 
			image_url => $_->movie->image_url,
			title => $_->movie->title, 
			user => $_->user->username 
		};
	} @latest;

	my @descKeys = sort { $b <=> $a } keys %viewbag;
    return template 'index', { latest => \%viewbag, keys => \@descKeys };
};

get '/about' => sub { 
	return template 'general/about';
};

### END GENERAL CONTROLLER

### ACCOUNT CONTROLLER

get '/login' => sub {
	return template 'account/login';
};

post '/login' => sub {
	my ($success, $realm) = authenticate_user(params->{username}, params->{password});
    if ($success) {
        session logged_in_user => params->{username};
        session logged_in_user_realm => $realm;
        
        return template 'general/message', {
        	alert_class => 'success',
        	message => 'You are logged in!',
        	redirectUrl => '/'
    	};
    } 
	return template 'account/login', { message => 'Login failed.', alert_class => 'danger' };
};

get '/login/denied' => sub {
	return template 'account/denied';
};

get '/logout' => sub {
	session->destroy;

	return template 'general/message', {
		alert_class => 'info',
		redirectUrl => '/',
		message => 'You have logged out!'
	}
};

get '/register' => sub {
	return template 'account/register';
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

get '/profile' => require_login sub {
	my $schema = MovieWorld::Schema->connect($dsn);
	my $count = logged_in_user->user_reviews->count;

	return template 'account/profile', { count => $count };
};

### END ACCOUNT CONTROLLER

### MOVIE CONTROLLER

get '/add-movie' => require_login sub {
	return template 'movie/add_movie';
};

post '/add-movie' => require_login sub {
	my $film = new IMDB::Film(crit => params->{title});

	unless (defined $film->title) {
		return template 'general/message', {
			message => 'Movie not found!',
			alert_class => 'danger',
			redirectUrl => '/add-movie'
		};
	}
	my $schema = MovieWorld::Schema->connect($dsn);

	my $doesExist = $schema->resultset('Movie')->search( { title => params->{title} } )->next;
	unless ($doesExist) {
		my $movie = $schema->resultset('Movie')->new({ 
			id => $film->code(),
			title => $film->title(),
			image_url => $film->cover()
		});
		$movie->insert;
	}

	my $review = $schema->resultset('Review')->new({
		review => params->{review},
		rating => params->{rating}
	});
	$review->insert;

	my $reviewWithID= $schema->resultset('Review')->search( { review => params->{review} })->next;
	my $link = $schema->resultset('UserReview')->new({
		user_id => logged_in_user->id,
		review_id => $reviewWithID->id,
		movie_id => $film->code()
	});
	$link->insert;

	return template 'general/message', { 
		message => 'Movie added successfully!',
		alert_class => 'success',
		redirectUrl => '/my-movies'
	};
};

get '/my-movies' => require_login sub {
	my $schema = MovieWorld::Schema->connect($dsn);
	my @user_reviews = logged_in_user->user_reviews(undef, { order_by => 'review_id' });
	my %viewbag;

	map {
		$viewbag{$_->movie->title} = { review => $_->review, image_url => $_->movie->image_url };
	} @user_reviews;

	return template 'movie/my_movies', { viewbag => \%viewbag };
};

get '/review/:id' => sub {
	my $schema = MovieWorld::Schema->connect($dsn);
	my $link = $schema->resultset('UserReview')->search({ review_id => params->{id}})->next;
	my %viewbag;

	unless (defined $link->review->hits) {
		$link->review->hits(0)
	}

	$link->review->hits($link->review->hits + 1);
	$link->review->update;

	$viewbag{movie} = $link->movie;
	$viewbag{user} = $link->user->username;
	$viewbag{review} = $link->review;

	return template 'movie/review', { viewbag => \%viewbag };
};

get '/movie' => sub {
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

get '/moviesearch' => sub {
	return template 'movie/movie_search'
};

### END MOVIE CONTROLLER

### API

get '/movie-image/:title' => sub {
	my $film = new IMDB::Film(crit => params->{title});

	content_type 'text/plain';
	return $film->cover();
};

### END API


1;