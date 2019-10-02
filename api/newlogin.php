<?php
function generateRandomString($length = 6) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyz';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}

$code = generateRandomString();


require_once("phpqrcode.php");
ob_start();
QRCode::png($code, null, QR_ECLEVEL_H, 7, 1);
$qrcode = base64_encode( ob_get_contents() );
ob_end_clean();

$data = array(
	"qrcode" => $qrcode,
	"code" => $code,
	"status" => "waiting"
);

echo json_encode($data);
?>