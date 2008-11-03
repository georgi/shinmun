<?php

$guid_pattern = "/^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$/";
$req = $_REQUEST;
$guid = $req['guid'];

preg_match($guid_pattern, $guid) or die("invalid guid");

$file = 'comments/' . $guid;

if ($_SERVER['REQUEST_METHOD'] == 'POST') {

  // create a comment record
  $record = array(date('Y-m-d H:i:s'), 
		  strip_tags(stripslashes($req['name'])),
		  strip_tags(stripslashes($req['website'])),
		  strip_tags(stripslashes($req['text'])));

  // encode as json string
  $json = json_encode($record) . "\n";

  // open the comment file for appending
  $fp = fopen($file, "a");

  // acquire a write lock
  flock($fp, LOCK_EX);

  // append the json line
  fwrite($fp, $json);

  // release lock
  flock($fp, LOCK_UN);

  // close file and release lock
  fclose($fp);
}

if (file_exists($file)) {

  // open the comment file for reading
  $fp = fopen($file, "r");

  // acquire a read lock
  flock($fp, LOCK_SH);

  // read whole file and print it out
  echo fread($fp, filesize($file));

  // release lock
  flock($fp, LOCK_UN);

  // close file
  fclose($fp);
}

?>