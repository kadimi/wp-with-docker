<?php

shell_exec('php setup.php db-port');
$db_port = trim(file_get_contents('db-port'));

$max_tries = 60;
echo 'Waiting for database';
do {
    set_error_handler(function() {});
    $mysql = new mysqli("0.0.0.0", 'wordpress', 'wordpress', 'wordpress', $db_port);
    restore_error_handler();
    if ($mysql->connect_error) {
        --$max_tries;
        if ($max_tries <= 0) {
            echo ' - Database not responding' . "\n";
            exit(1);
        }
        echo '.';
        sleep(1);
    }
} while ($mysql->connect_error);
echo ' - Database ready' . "\n";