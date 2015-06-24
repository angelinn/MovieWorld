package MovieWorld::Schema::Result::User;
 
use strict;
use warnings;
 
use base qw/ DBIx::Class::Core /;
 
__PACKAGE__->load_components(qw/EncodedColumn Core/);
__PACKAGE__->table('Users');
__PACKAGE__->add_columns(
    id => {
        data_type => 'INTEGER',
        is_auto_increment => 1,
        is_nullable => 0,
    },
    username => {
        data_type => 'VARCHAR',
        size => 32,
        is_nullable => 0,
    },
    password => {
        data_type => 'VARCHAR',
        size => 40,
        is_nullable => 0,
        encode_column => 1,
        encode_class  => 'Digest',
        encode_args   => { 
            algorithm => 'SHA-1', 
            format => 'hex',
        },
        encode_check_method => 'check_password',
    },
);
 
__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->add_unique_constraint( 'username' => [ 'username' ] );
 
__PACKAGE__->has_many( 
    user_roles => 'MovieWorld::Schema::Result::UserReview', 'user_id'
);

1;