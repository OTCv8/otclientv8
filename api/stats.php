<?php
$data = file_get_contents("php://input");
$json = json_decode($data);
if(!$json || !$json->uid) {
    die();    
}

if($json->uid) {
    file_put_contents("stats/".($json->uid).".log", "\n".$data."\n", FILE_APPEND);
}

echo "OK";
?>