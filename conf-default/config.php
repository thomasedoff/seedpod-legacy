<?php
  // rutorrent config
  // https://github.com/Novik/ruTorrent/wiki/Config#configphp

  @define('HTTP_USER_AGENT', 'Mozilla/5.0 (Windows NT 6.0; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0', true);
  @define('HTTP_TIME_OUT', 30, true);
  @define('HTTP_USE_GZIP', true, true);
  @define('RPC_TIME_OUT', 5, true);
  @define('LOG_RPC_CALLS', false, true);
  @define('LOG_RPC_FAULTS', true, true);
  @define('PHP_USE_GZIP', false, true);
  @define('PHP_GZIP_LEVEL', 2, true);

  $httpIP = null;
  $schedule_rand = 10;
  $do_diagnostic = true;
  $log_file = '/proc/self/fd/1';
  $saveUploadedTorrents = false;
  $overwriteUploadedTorrents = false;
  $topDirectory = '/';
  $forbidUserSettings = true;

  $scgi_port = 0;
  $scgi_host = "unix:///tmp/rpc.socket";
  $XMLRPCMountPoint = "/RPC2";

  $pathToExternals = array(
    "php"   => '/usr/bin/php',
    "curl"  => '/usr/bin/curl',
    "gzip"  => '/usr/bin/gzip',
    "id"    => '/usr/bin/id',
    "stat"  => '/usr/bin/stat',
    "python" => '/usr/bin/python',
    "pgrep" => '/usr/bin/pgrep'
  );

  $localhosts = array(
    "127.0.0.1",
    "localhost",
  );

  $profilePath = '/home/seedpod/rutorrent';
  $profileMask = 0700;
  $tempDirectory = null;
  $canUseXSendFile = true;
