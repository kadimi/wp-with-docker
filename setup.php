<?php

switch ($_SERVER['argv'][1]) {
    case 'db-port':
    if(!file_exists('db-port')) {
        file_put_contents('db-port', rand(33000, 33999));
    }
    break;
};
