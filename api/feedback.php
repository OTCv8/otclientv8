<?php
$data = file_get_contents("php://input");
//$data = json_decode($data);
if(empty($data)) {
	return http_response_code(400);
}

file_put_contents("feedback.txt", $data."\n\n\n", FILE_APPEND);

echo "OK";
?>