use strict;
use warnings;
use utf8;
use Test::Declare;
use YAML;

use lib './t';
use Mock::Basic;

plan tests => blocks;

describe 'update test' => run {
    init {
        Mock::Basic->setup_test_db;
        Mock::Basic->insert('mock_basic',{
            id   => 1,
            name => 'perl',
        });
    };

    test 'update mock_basic data' => run {
        ok +Mock::Basic->update('mock_basic',{name => 'python'},{id => 1});
        my $row = Mock::Basic->single('mock_basic',{id => 1});

        isa_ok $row, 'DBIx::Skinny::Row';
        is $row->name, 'python';
    };

    test 'row object update' => run {
        my $row = Mock::Basic->single('mock_basic',{id => 1});
        is $row->name, 'python';

        ok $row->update({name => 'perl'});
        my $new_row = Mock::Basic->single('mock_basic',{id => 1});
        is $new_row->name, 'perl';
    };

    cleanup {
        if ( $ENV{SKINNY_PROFILE} ) {
            warn "query log";
            warn YAML::Dump(Mock::Basic->profiler->query_log);
        }
    };
};

