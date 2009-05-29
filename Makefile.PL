use inc::Module::Install;

name     'DBIx-Class-PhoneticSearch';
all_from 'lib/DBIx/Class/PhoneticSearch.pm';
author   'Moritz Onken <onken@netcubed.de>';
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

