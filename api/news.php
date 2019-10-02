<?php

$news = array();
$lang = "en";
if(isset($_GET['lang']))
	$lang = $_GET['lang'];

$jokes = array();
$jokes[] = "How do you make a tissue dance? You put a little boogie in it.";
$jokes[] = "Why did the policeman smell bad? He was on duty.";
$jokes[] = "Why does Snoop Dogg carry an umbrella? FO DRIZZLE!";
$jokes[] = "Why can't you hear a pterodactyl in the bathroom? Because it has a silent pee.";
$jokes[] = "What did the Zen Buddist say to the hotdog vendor? Make me one with everything.";
$jokes[] = "What kind of bees make milk instead of honey? Boobies.";
$jokes[] = "Horse walks into a bar. Bartender says, 'Why the long face?'";
$jokes[] = "A mushroom walks into a bar. The bartender says, 'Hey, get out of here! We don't serve mushrooms here'. Mushroom says, 'why not? I'm a fungai!'";
$jokes[] = "I never make mistakes…I thought I did once; but I was wrong.";
$jokes[] = "What's Beethoven's favorite fruit? Ba-na-na-naaa!";
$jokes[] = "What did the little fish say when he swam into a wall? DAM!";
$jokes[] = "Knock knock. Who's there? Smell mop. (finish this joke in your head)";
$jokes[] = "Where does a sheep go for a haircut? To the baaaaa baaaaa shop!";
$jokes[] = "What does a nosey pepper do? Gets jalapeno business!";
$jokes[] = "Your mom is so poor, she even can't pay attention";

$news[] = array("title" => "TEST SERVERS", "text" => "OTCLIENTV8 Accs:\nacc1/acc\nacc2/acc\nacc3/acc");

$news[] = array("title" => "First title", 
	"text" => "This is example of lua g_http api. Those news are from http://otclient.ovh/news.php
	\nRequest was for language '".$lang."', however, there's only english version of this, don't have time to create more versions");
$news[] = array("title" => "Random joke", "text" => $jokes[array_rand($jokes)]);
$news[] = array("title" => "Image test", "image" => base64_encode(file_get_contents("image.png")));

echo json_encode($news);

?>