<?php
$data = file_get_contents("php://input", false, stream_context_get_default(), 0, $_SERVER["CONTENT_LENGTH"]);
if($_REQUEST['txt'] == 1) {
    file_put_contents("crashes/".time()."_".$_SERVER['REMOTE_ADDR'].".txt", $data);
} else if($_REQUEST['txt'] == 2) {
    file_put_contents("crashes/".time()."_".$_SERVER['REMOTE_ADDR'].".log", $data);
} else {
    file_put_contents("crashes/".time()."_".$_SERVER['REMOTE_ADDR'].".dmp", $data);
}
echo "OK";
?>