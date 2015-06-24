package MovieWorld::Schema::Result::UserReview;
 
use strict;
use warnings;
 
use base qw/ DBIx::Class::Core /;

__PACKAGE__->table('UserReview');
 
__PACKAGE__->add_columns(
    user_id => {
        data_type => 'INTEGER',
        is_foreign_key => 1,
        is_nullable => 0,
    },
    review_id => {
        data_type => 'INTEGER',
        is_foreign_key => 1,
        is_nullable => 0,
    },
    movie_id => {
        data_type => 'INTEGER',
        is_foreign_key => 1,
        is_nullable => 0,
    }
);
 
__PACKAGE__->set_primary_key( 'user_id', 'review_id' );
 
__PACKAGE__->belongs_to( 
    user => 'MovieWorld::Schema::Result::User', 'user_id'
);
    
__PACKAGE__->belongs_to( 
    review => 'MovieWorld::Schema::Result::Review', 'review_id'
);

__PACKAGE__->belongs_to( 
    movie => 'MovieWorld::Schema::Result::Movie', 'movie_id'
);
 
1;