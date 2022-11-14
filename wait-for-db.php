<?php

shell_exec('php setup.php db-port');
$db_port = trim(file_get_contents('db-port'));

$max_tries = 60;
echo 'Waiting for database' . "\n";
do {
    try {
        set_error_handler(function() {});
        $mysqli = new mysqli("0.0.0.0", 'wordpress', 'wordpress', 'wordpress', $db_port);
        restore_error_handler();
        break;
    } catch (\Throwable $th) {
        --$max_tries;
        if ($max_tries < 0) {
            echo "\n" . 'Database not responding';
            exit(1);
        }
        echo '-';
        sleep(1);
    }
} while (true);
echo "\n" . 'Database ready';