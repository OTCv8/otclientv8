<?php
// author otclient@otclient.ovh
// config
$dbserver = "127.0.0.1";
$username = "otclient";
$password = "otclient";
$dbname = "otclient";

$serverName = "OTClientV8";
$serverIp = "otclient.ovh";
//$serverIp = "proxy";   // if serverIp set to 0.0.0.0 or proxy it will connect to server using proxies, set proxies bellow
$serverPort = 7172; // GAME PORT (7172 usually)

$version = 1099;
$otc_version = 1337; // APP_VERSION, from init.lua

$maxLogins = 10; // 0 or null to disable
$blockTime = 60; // after too many logins, in seconds
// CREATE TABLE `login_attmpts` ( `acc` varchar(50) NOT NULL, `ip` varchar(30) NOT NULL, `date` datetime NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

$encryption = "sha1"; // sha1 or md5, everything else == none 

// required files in things, type => (filename, md5 checksum in hex)
// $things = null; things can be null if you want to use default values, but then enable auto download of sprites and dat in updater 

/* //for 860
$things = array(
    "sprites" => array("$version/Tibia.spr", "3db8c0098d34ca3d9a8ec29d40ef1b7b"), 
    "data" => array("$version/Tibia.dat", "85785b5d67b4c111f780a74895c85c75")
); 
*/

// for 1099
$things = array(
    "sprites" => array("$version/Tibia.spr", "63d38646597649a55a8be463d6c0fb49"), 
    "data" => array("$version/Tibia.dat", "ae7157cfff42f14583d6363e77044df7")
);

$customProtocol = nil; // if not nil it will replace client version in protocolgame, may be used to detect outdated client

// executes modules.client_options.setOption(option, value, true)
$settings = array(
    
);

// it's from src/client/const.h, executes g_game.enableFeature/g_game.disableFeature
$features = array(
    22 => true, // GameFormatCreatureName
    25 => true, // GameExtendedClientPing
    30 => true, // GameChangeMapAwareRange
//    56 => true, // GameSpritesAlphaChannel
    80 => true,
    90 => true, // GameNewWalking
//    91 => true, // GameSmootherWalking
    95 => true, // GameBot
    97 => true, // light
);

$rsa = "1091201329673994292788609605089955415282375029027981291234687579" .
              "3726629149257644633073969600111060390723088861007265581882535850" .
              "3429057592827629436413108566029093628212635953836686562675849720" .
              "6207862794310902180176810615217550567108238764764442605581471797" .
              "07119674283982419152118103759076030616683978566631413";
                            
// proxies (it's custom feature, not available for free)
$proxies = array(
    array(
        "localPort" => 7172,
        "host" => "51.158.184.57",
        "port" => 7162,
        "priority" => 0
    ),
    array(
        "localPort" => 7172,
        "host" => "54.39.190.20",
        "port" => 7162,
        "priority" => 0
    ),
    array(
        "localPort" => 7172,
        "host" => "51.83.226.109",
        "port" => 7162,
        "priority" => 0,
    ),
    array(
        "localPort" => 7172,
        "host" => "35.247.201.100",
        "port" => 443,
        "priority" => 0
    )
);              

// config end

$data = file_get_contents("php://input");

$data = json_decode($data);
if(empty($data)) {
	http_response_code(400);
}

if($data->version != $otc_version) {
    die(json_encode(array("error" => "Outdated client, please update!")));
}

$conn = new mysqli($dbserver, $username, $password, $dbname);
if ($conn->connect_error) {
    die("SQL connection failed: " . $conn->connect_error);
}

if($data->quick == 1) { 
    require_once("quick.php");
    
    die();
}

$account = $data->account;
if($encryption == "sha1")
    $password = sha1($data->password);
else if($encryption == "md5")
    $password = md5($data->password);
else
    $password = $data->password;

$token = $data->token;

$account = preg_replace("/[^A-Za-z0-9 ._-]/", '', $account);
$password = preg_replace("/[^A-Za-z0-9 ._-]/", '', $password);
$token = preg_replace("/[^A-Za-z0-9 ._-]/", '', $token);
$ip = preg_replace("/[^A-Za-z0-9 ._-]/", '', $_SERVER['REMOTE_ADDR']);

if($maxLogins != null && $maxLogins > 0) {
    $result = $conn->query("select count(*) as `attempts` from `login_attmpts` where `ip` = '".$ip."' and `date` > NOW() - INTERVAL ".$blockTime." SECOND");
    $result = $result->fetch_assoc();    
    if($result['attempts'] > $maxLogins) {
        die(json_encode(array("error" => "Too many login attempts, please wait ".$blockTime." seconds.")));        
    }
    $conn->query("INSERT INTO `login_attmpts` (`acc`, `ip`, `date`) VALUES ('".$conn->real_escape_string($account)."', '".$ip."', NOW())");
}

$result = $conn->query("select * from accounts where `name` = '".$conn->real_escape_string($account)."' and `password` = '".$conn->real_escape_string($password)."'");
if ($result->num_rows != 1) {
	die(json_encode(array("error" => "Invalid account/password")));
}
$acc = $result->fetch_assoc();

$session = "".$data->account."\n".$data->password."\n$token\n".time();

if($serverIp != "proxy" && $serverIp != "0.0.0.0") {
    $proxies = null;
}

$response = array(
    "error" => "",
    "rsa" => $rsa,
    "version" => $version,
    "things" => $things,
    "customProtocol" => $customProtocol,
    "session" => $session,
    "characters" => array(),
    "account" => array(),
    "settings" => $settings,
    "features" => $features,
    "proxies" => $proxies
);

$response["account"]["status"] = 0; // 0=ok, 1=frozen, 2=supsended
$response["account"]["subStatus"] = 1; // 0=free, 1=premium
$response["account"]["premDays"] = 65535;

$characters = $conn->query("select * from `players` where `account_id` = '".$acc['id']."'");
if ($characters->num_rows == 0) {
	die(json_encode(array("error" => "Account doesn't have any characters")));
}

while($character = $characters->fetch_assoc()) {
	$response["characters"][] = array(
		"name" => $character['name'],
		"worldName" => $serverName,
		"worldIp" => $serverIp,
		"worldPort" => $serverPort
        // if you are good enough and can code it in lua, you can add outfit, level, vocation, whatever you want here
	);
}

echo json_encode($response);
?>