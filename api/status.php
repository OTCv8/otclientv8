<?php
$online_otservlist = 0;
try {
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, "https://otservlist.org/");
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); // Return data inplace of echoing on screen
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); // Skip SSL Verification
    curl_setopt($ch, CURLOPT_ENCODING , "");
	$site = curl_exec($ch);
	curl_close($ch);
    
    preg_match('/There are <strong>([0-9]*)<\/strong>/', $site, $matches);
    $online_otservlist = $matches[1];
} catch(Exception $e) {}
$online_discord = 0;
try {
    $online_discord = json_decode(file_get_contents("https://discordapp.com/api/guilds/628769144925585428/widget.json"))->presence_count;
} catch(Exception $e) {}

$response = array(
    "online" => "$online_otservlist Players online",
    "discord_online" => $online_discord,
    "discord_link" => "https://discord.gg/t4ntS5p" 
);
echo json_encode($response);
?>