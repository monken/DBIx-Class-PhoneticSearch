#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'DBIx::Class::SearchPhonetic' );
}

diag( "Testing DBIx::Class::SearchPhonetic $DBIx::Class::SearchPhonetic::VERSION, Perl $], $^X" );
