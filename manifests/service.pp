define tomcat::service (
  $basedir,
  $bind_address,
  $check_port,
  $config,
  $cpu_affinity,
  $dependencies,
  $down,
  $ensure,
  $filestore,
  $gclog_enabled,
  $gclog_numfiles,
  $gclog_filesize,
  $group,
  $localhost,
  $logdir,
  $java_home,
  $java_opts,
  $max_mem,
  $min_mem,
  $product,
  $ulimit_nofile,
  $user,
  $version,
) {
  $product_dir = "${basedir}/${product}-${version}"

}
