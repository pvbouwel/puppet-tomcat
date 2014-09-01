define tomcat::instance (
  $basedir          = $::tomcat::basedir,
  $bind_address     = $::tomcat::bind_address,
  $check_port       = $::tomcat::check_port,
  $config           = $::tomcat::config,
  $connectors       = undef,
  $cpu_affinity     = $::tomcat::cpu_affinity,
  $dependencies     = $::tomcat::dependencies,
  $down             = $::tomcat::down,
  $files            = $::tomcat::files,
  $filestore        = $::tomcat::filestore,
  $gclog_enabled    = $::tomcat::gclog_enabled,
  $gclog_numfiles   = $::tomcat::gclog_numfiles,
  $gclog_filesize   = $::tomcat::gclog_filesize,
  $group            = $::tomcat::group,
  $java_home        = $::tomcat::java_home,
  $java_opts        = $::tomcat::java_opts,
  $localhost        = $::tomcat::localhost,
  $logdir           = $::tomcat::logdir,
  $max_mem          = $::tomcat::max_mem,
  $min_mem          = $::tomcat::min_mem,
  $mode             = $::tomcat::mode,
  $remove_docs      = $::tomcat::remove_docs,
  $remove_examples  = $::tomcat::remove_examples,
  $templates        = $::tomcat::templates,
  $ulimit_nofile    = $::tomcat::ulimit_nofile,
  $user             = $::tomcat::user,
  $version          = $::tomcat::version,
  $workspace        = $::tomcat::workspace,
) {
  if ! $version {
    fail( 'tomcat version MUST be set' )
  }
  $instancename        = $title
  $product     = 'apache-tomcat'
  $product_dir = "${basedir}/${instancename}/${product}-${version}"

  if ! defined(File[$workspace]) {
    file { $workspace:
      ensure => directory,
    }
  }

  if ! defined(Group[$group]) {
    group { "${group}":
      ensure => 'present',
    }  
  }
  if ! defined(User[$user]) {    
    user { "${user}":
      ensure           => 'present',
      comment          => 'Apache tomcat user',
      gid              => "${group}",
      password         => '!!',
      password_max_age => '-1',
      password_min_age => '-1',
      shell            => '/sbin/nologin',
      managehome       => true,
    }
  }
  

  tomcat::install { "${instancename}-${product}":
    basedir         => $basedir,
    filestore       => $filestore,
    group           => $group,
    instancedir     => $instancename,
    java_home       => $java_home,
    logdir          => $logdir,
    ulimit_nofile   => $ulimit_nofile,
    user            => $user,
    version         => $version,
    workspace       => $workspace,
  }

  if ! $templates['bin/startup.sh'] {
    file { "${product_dir}/bin/startup.sh":
      ensure   => present,
      owner    => $user,
      group    => $group,
      mode     => $mode,
      content  => template('tomcat/startup.sh.erb'),
      require  => Exec["tomcat-unpack-${instancename}"],
    }
  }

  if ! $templates['conf/server.xml'] {
    file { "${product_dir}/conf/server.xml":
      ensure   => present,
      owner    => $user,
      group    => $group,
      mode     => $mode,
      content  => template('tomcat/server.xml.erb'),
      require  => Exec["tomcat-unpack-${instancename}"],
    }
  }

  if ! $templates['conf/logging.properties'] {
    file { "${product_dir}/conf/logging.properties":
      ensure   => present,
      owner    => $user,
      group    => $group,
      mode     => $mode,
      content  => template('tomcat/logging.properties.erb'),
      require  => Exec["tomcat-unpack-${instancename}"],
    }
  }

  create_resources_with_prefix( 'tomcat::file', $files,
    {
      group         => $group,
      instancename  => $instancename,
      mode          => $mode,
      product_dir   => $product_dir,
      user          => $user,
    },
    "${product_dir}/",
  )

  create_resources_with_prefix( 'tomcat::template', $templates,
    {
      basedir         => $basedir,
      bind_address    => $bind_address,
      check_port      => $check_port,
      config          => $config,
      cpu_affinity    => $cpu_affinity,
      dependencies    => $dependencies,
      down            => $down,
      filestore       => $filestore,
      group           => $group,
      java_home       => $java_home,
      java_opts       => $java_opts,
      localhost       => $localhost,
      logdir          => $logdir,
      max_mem         => $max_mem,
      min_mem         => $min_mem,
      mode            => $mode,
      product_dir     => $product_dir,
      ulimit_nofile   => $ulimit_nofile,
      user            => $user,
      version         => $version,
      workspace       => $workspace,
    },
    "${product_dir}/",
  )

  if $remove_docs {
    file { "${product_dir}/webapps/docs":
      ensure  => absent,
      recurse => true,
      force   => true,
      purge   => true,
      backup  => false,
      require => Exec["tomcat-unpack-${instancename}"],
    }
  }

  if $remove_examples {
    file { "${product_dir}/webapps/examples":
      ensure  => absent,
      recurse => true,
      force   => true,
      purge   => true,
      backup  => false,
      require => Exec["tomcat-unpack-${instancename}"],
    }
  }

  tomcat::service { "${instancename}-${product}":
    basedir         => $basedir,
    bind_address    => $bind_address,
    check_port      => $check_port,
    dependencies    => $dependencies,
    gclog_enabled   => $gclog_enabled,
    gclog_numfiles  => $gclog_numfiles,
    gclog_filesize  => $gclog_filesize,
    localhost       => $localhost,
    logdir          => $logdir,
    product         => $product,
    user            => $user,
    filestore       => $filestore,
    group           => $group,
    version         => $version,
    java_home       => $java_home,
    java_opts       => $java_opts,
    config          => $config,
    cpu_affinity    => $cpu_affinity,
    min_mem         => $min_mem,
    max_mem         => $max_mem,
    down            => $down,
    ulimit_nofile   => $ulimit_nofile,
  }

}
