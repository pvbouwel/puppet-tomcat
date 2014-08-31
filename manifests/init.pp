class tomcat (
  $version          = undef,
  $basedir          = '/opt/tomcat',
  $bind_address     = $::fqdn,
  $check_port       = '8080',
  $config           = {},
  $cpu_affinity     = undef,
  $dependencies     = undef,
  $down             = false,
  $files            = {},
  $filestore        = 'puppet:///files/tomcat',
  $gclog_enabled    = false,
  $gclog_numfiles   = '5',
  $gclog_filesize   = '100M',
  $group            = 'tomcat',
  $localhost        = 'localhost',
  $logdir           = '/var/log/tomcat',
  $java_home        = '/usr/java/latest',
  $java_opts        = '',
  $max_mem          = '2048m',
  $min_mem          = '1024m',
  $mode             = undef,
  $remove_docs      = true,
  $remove_examples  = true,
  $templates        = {},
  $ulimit_nofile    = '$(ulimit -H -n)',
  $user             = 'tomcat',
  $workspace        = '/root/tomcat',
) {
  $tomcat = hiera_hash('tomcat::instances', undef)
  if $tomcat {
    create_resources('tomcat::instance', $tomcat)
  }
}
