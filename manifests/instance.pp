define tomcat::instance (
  $basedir          = $::tomcat::basedir,
  $bind_address     = $::tomcat::bind_address,
  $check_port       = $::tomcat::check_port,
  $config           = $::tomcat::config,
  $connectors       = undef,
  $cpu_affinity     = $::tomcat::cpu_affinity,
  $dependencies     = $::tomcat::dependencies,
  $down             = $::tomcat::down,
  $ensure           = 'present',
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
  $site_specific    = $::tomcat::site_specific,
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
  
  if $instancename == "NONAME" {
    $final_instancedir = ""
  } else {
    $final_instancedir = "/${instancename}"
  }
  $instance_dir = "${basedir}${final_instancedir}"
  $product_dir = "${instance_dir}/${product}-${version}"

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
      shell            => '/bin/bash',
      managehome       => true,
    }
  }
  
  if $ensure == 'present' {
    tomcat::install { "${instancename}-${product}":
      basedir         => $basedir,
      filestore       => $filestore,
      group           => $group,
      instancedir     => $instance_dir,
      instancename    => $instancename,
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
    } else {
      file { "${product_dir}/bin/startup.sh":
        ensure   => present,
        owner    => $user,
        group    => $group,
        mode     => $mode,
        content  => template($templates['bin/startup.sh']),
        require  => Exec["tomcat-unpack-${instancename}"],
      }
    }

    if ! $templates['server.xml'] {
      file { "${product_dir}/conf/server.xml":
        ensure   => present,
        owner    => $user,
        group    => $group,
        mode     => $mode,
        content  => template('tomcat/server.xml.erb'),
        require  => Exec["tomcat-unpack-${instancename}"],
      }
    } else {
      file { "${product_dir}/conf/server.xml":
        ensure   => present,
        owner    => $user,
        group    => $group,
        mode     => $mode,
        content  => template($templates['server.xml']),
        require  => Exec["tomcat-unpack-${instancename}"],
      }
    }

    if ! $templates['logging.properties'] {
      file { "${product_dir}/conf/logging.properties":
        ensure   => present,
        owner    => $user,
        group    => $group,
        mode     => $mode,
        content  => template('tomcat/logging.properties.erb'),
        require  => Exec["tomcat-unpack-${instancename}"],
      }
    } else {
      file { "${product_dir}/conf/logging.properties":
        ensure   => present,
        owner    => $user,
        group    => $group,
        mode     => $mode,
        content  => template($templates['logging.properties']),
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
    
    tomcat::service_script { "${instancename}-${product}":
      product_dir   => $product_dir,
      ensure        => present,
      user          => $user,
      java_home     => $java_home,
      templates     => $templates,
      instancename => $instancename,
    }      
  }elsif $ensure != 'present' {
    if $instancename == "NONAME" {
      notify{"Deletion of instances without a name is not implemented because it might delete too much.":}
      #Optionally it can be implemented that it is checked whether a tomcat symbolic link is present and that
      #the target is removed and subsequently the link itself.
    }else {
      tomcat::service_script { "${instancename}-${product}":
        product_dir   => $product_dir,
        ensure        => absent,
        user          => $user,
        java_home     => $java_home,
        templates     => $templates,
        instancename => $instancename,
      }->
      ##Remove tomcat
      file{ "${instance_dir}":
        ensure => absent,
        recurse => true,
        force => true,
        purge => true,
        backup => false,
      } 
    }
  } else {
    err("Unknown ensure value (${ensure})")
  }
}
