<?php

$req = $_REQUEST;
$guid = $req['guid'] or die('guid missing');
$file = 'comments/' . $guid;

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
  $record = array(date('Y-m-d H:i:s'), $req['name'], $req['website'], $req['text']);
  $json = json_encode($record);
  file_put_contents($file, $json . "\n", -1);
}

if (file_exists($file)) {
  readfile($file);
}

?>