package MovieWorld::Schema::Result::Movie;
 
use strict;
use warnings;
 
use base qw/ DBIx::Class::Core /;
 
__PACKAGE__->table('Movies');
__PACKAGE__->add_columns(
    id => {
        data_type => 'INTEGER',
        is_nullable => 0,
    },
    title => {
        data_type => 'VARCHAR',
        size => 64,
        is_nullable => 0,
    }
);

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many( 
    user_reviews => 'MovieWorld::Schema::Result::UserReview', 'movie_id'
);

1;