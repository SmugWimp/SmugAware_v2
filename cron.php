<?php
	// 
	define("MY_URL", "http://yourserver.com/data/aircraft.json");
	define("KEY_FILE", "/path/to/key.txt");
	define("MY_FILEPATH", "/path/to/data.json");
	//
	
	//// Leave this alone... it loops once per second for 15 minutes, then stops.
	//// We setup a cron job to run 4 times per hour, triggering this script.
	//// */15	*	*	*	*	/opt/php54/bin/php /path/to/script/cron.php >/dev/null 2>&1
	//// if you need to stop the script, create a file in the directory called 'key.txt'. It can be blank.
	//// delete it when you're ready to let the script roll again...

	/*
	$success = file_get_contents(MY_URL);			
	$myJson = json_decode($success);
	$myAircraft = $myJson->aircraft;
	$newJson = json_encode($myAircraft);
	$myResult = file_put_contents(MY_FILEPATH, $newJson);
	*/

	$start = microtime(true);
	set_time_limit(900);
	for ($i = 0; $i < 899; ++$i) {
		if ($myBool == False) {
			$myBool = file_exists(KEY_FILE);
			// if you ever have to do any maintenance and you can't stop the script, 
			// place a file called 'key.txt' in the directory. The script
			// will continue to run and count down, but it won't actually do anything.
			// be sure to delete it when you're done.
			$success = file_get_contents(MY_URL);			
			$myJson = json_decode($success);
			$myAircraft = $myJson->aircraft;
			$newJson = json_encode($myAircraft);
			$myResult = file_put_contents(MY_FILEPATH, $newJson);
 
		} else {
			// uncomment the next 2 lines, if you want to substitute a 'test' file in place of any available live data.
			// replace values with valid entries for best results.
//			$success = file_get_contents("/filepath/to/test_data.json");
//			$myResult = file_put_contents("MY_FILEPATH", $success);
		}
		time_sleep_until($start + $i + 1);
		// uncomment the next line if you want the 'key.txt' file to be deleted at the end of the script time.
//		unlink(KEY_FILE);
	}
?>

