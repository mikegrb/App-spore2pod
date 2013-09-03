requires 'perl', '5.008005';

requires 'App::Cmd';
requires 'JSON', '2';

on test => sub {
    requires 'Test::More', '0.88';
};
