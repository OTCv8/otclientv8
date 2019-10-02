<?php
// set chmod 777 to dir with this file to create checksum files
$data = file_get_contents("php://input");
$data = json_decode($data);
if(!empty($data)) {
    $platform = $data->platform;
    $version = $data->version; // currently not used
}

if($platform == "WIN32-WGL") { // opengl
    $binary_path = "/otclient_gl.exe";
    $checksums_file = "checksums_gl.txt";
} else if($platform == "WIN32-EGL") { // dx
    $binary_path = "/otclient_dx.exe"; 
    $checksums_file = "checksums_dx.txt";
} else {
    $binary_path = "";
    $checksums_file = "checksums.txt";
}

$data_dir = "/var/www/otclient/files";
$things_dir = "/data/things"; // files from that dir won't be downloaded automaticly, you can set it to null to download everything automaticly (useful if you have only 1 version of data/sprites)
$files_url = "http://otclient.ovh/files";
$update_checksum_interval = 60; // caling updater 100x/s would lag disc, we need to cache it
$main_files_and_dirs = array("data", "modules", "init.lua"); // used to ignore other files/dirs in data_dir

// CONFIG END

$data = array("url" => $files_url, "files" => array(), "things" => array(), "binary" => $binary_path);

function getDirFiles($dir, &$results = array()){
    $files = scandir($dir);

    foreach($files as $key => $value){
        $path = realpath($dir.DIRECTORY_SEPARATOR.$value);
        if(!is_dir($path)) {
            $results[] = $path;
        } else if($value != "." && $value != "..") {
            getDirFiles($path, $results);            
        }
    }
    return $results;
}

function updateChecksums() {
	global $data_dir;
	global $main_files_and_dirs;
    global $binary_path;
    global $checksums_file;
    global $data;
    global $things_dir;
    
	$ret = array();
	$data_dir_realpath = realpath($data_dir);
	$files = getDirFiles($data_dir);
	foreach($files as $file) {
		$relative_path = str_replace($data_dir_realpath, "", $file);
        $ps = explode("/", $relative_path);
        if($relative_path == $binary_path || (count($ps) >= 2 && in_array($ps[1], $main_files_and_dirs)))
            $ret[$relative_path] = md5_file($file);
	}	
    foreach($ret as $file => $checksum) {
        if($things_dir != null && !empty($things_dir) && strpos($file, $things_dir) === 0) {
            $data["things"][$file] = $checksum;
        } else {
            $data["files"][$file] = $checksum;    
        }
    }	    
    $ret = json_encode($data);
    if(file_put_contents($checksums_file, $ret) === FALSE) {
        echo "Can't create checksum file (try to set correct chmod) ". - $checksums_file;
        exit();
    }
	return $ret;
}

if (function_exists('sem_get')) {
    $semaphore = sem_get(18237192837, 1, 0666, 1);
    if(!$semaphore) 
    {
        echo "Failed to get semaphore - sem_get().\n";
        exit();
    }
        
    sem_acquire($semaphore);
}
$ft = filemtime($checksums_file);
if($ft === false || $ft + $update_checksum_interval < time()) {
    echo updateChecksums();
} else {
    echo file_get_contents($checksums_file);
}
if (function_exists('sem_get')) {
    sem_release($semaphore);
}
?>