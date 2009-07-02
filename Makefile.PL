use inc::Module::Install;

perl_version '5.8.1';
name 'BitIO';

all_from 'lib/BitIO.pm';

requires 'perl' => '5.8.1';
requires 'Params::Validate';
requires 'Class::Accessor::Lvalue::Fast';

auto_install;
WriteAll;
