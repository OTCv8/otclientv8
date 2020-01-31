<?php
$data = file_get_contents("php://input");
if(empty($data)) {
	return http_response_code(400);
}
$json = json_decode($data);
if(!$json) {
	return http_response_code(400);
}

file_put_contents("feedback.txt", ($json->player->name) .": ". ($json->text) ."\n".$data."\n\n\n", FILE_APPEND);

echo "OK";
?>