package MovieWorld::Schema::Result::Review;
 
use strict;
use warnings;
 
use base qw/ DBIx::Class::Core /;
 
__PACKAGE__->table('Reviews');
__PACKAGE__->add_columns(
    id => {
        data_type => 'INTEGER',
        size => 64,
        is_nullable => 0,
    },
    review => {
        data_type => 'VARCHAR',
        size => 512,
        is_nullable => 0,
    }
);
 
__PACKAGE__->set_primary_key( 'id' );
 
__PACKAGE__->has_many( 
    user_roles => 'MovieWorld::Schema::Result::UserReview', 'review_id'
);

1;