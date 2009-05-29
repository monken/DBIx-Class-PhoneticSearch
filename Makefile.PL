use inc::Module::Install;

name     'DBIx-Class-SearchPhonetic';
all_from 'lib/DBIx/Class/SearchPhonetic.pm';
author   'Moritz Onken <onken@netcubed.de>';
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

