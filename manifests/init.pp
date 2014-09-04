class tomcat (
  $version               = undef,
  $basedir               = '/opt/tomcat',
  $bind_address          = $::fqdn,
  $check_port            = '8080',
  $config                = {},
  $cpu_affinity          = undef,
  $dependencies          = undef,
  $down                  = false,
  $files                 = {},
  $filestore             = 'puppet:///files/tomcat',
  $gclog_enabled         = false,
  $gclog_numfiles        = '5',
  $gclog_filesize        = '100M',
  $group                 = 'tomcat',
  $localhost             = 'localhost',
  $logdir                = '/var/log/tomcat',
  $java_home             = '/usr/java/latest',
  $java_opts             = '',
  $max_mem               = '2048m',
  $min_mem               = '1024m',
  $mode                  = undef,
  $remove_docs           = true,
  $remove_examples       = true,
  $site_specific         = undef,
  $templates             = {},
  $tomcat_instances_hash = hiera_hash('tomcat::instances', undef),
  $ulimit_nofile         = '$(ulimit -H -n)',
  $user                  = 'tomcat',
  $workspace             = '/root/tomcat',
) {
  if $tomcat_instances_hash {
    create_resources('tomcat::instance', $tomcat_instances_hash)
  }
  
  file { "/etc/facter":
    ensure   => directory,
  }
 
  file { "/etc/facter/facts.d":
    ensure   => directory,
    require  => File["/etc/facter"],
  }
 
  $tomcat_version_path = "apache-tomcat-${version}"
  $template_tomcat_instances = undef
  
  if ! $templates['tomcat_instances.yaml'] {
    file { "/etc/facter/facts.d/tomcat_instances.yaml":
      ensure   => present,
      content  => template('tomcat/tomcat_instances.yaml.erb'),
      require  => File["/etc/facter/facts.d"],
    }
  } else {
    file { "/etc/facter/facts.d/tomcat_instances.yaml":
      ensure   => present,
      content  => template($templates['tomcat_instances.yaml']),
      require  => File["/etc/facter/facts.d"],
    }
  }
}
