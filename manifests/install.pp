define tomcat::install (
  $basedir,
  $filestore,
  $group,
  $java_home,
  $logdir,
  $instancedir,
  $ulimit_nofile,
  $user,
  $version,
  $workspace,
) {
  $tarball = "apache-tomcat-${version}.tar.gz"
  $subdir  = "apache-tomcat-${version}"

  if $instancedir == "NONAME" {
    $final_instancedir = ""
  } else {
    $final_instancedir = "/${instancedir}"
  }

  $baseinstancedir = "${basedir}/${final_instancedir}" 

  if ! defined(Package['tar']) {
    package { 'tar': ensure => installed }
  }
  if ! defined(Package['gzip']) {
    package { 'gzip': ensure => installed }
  }
  # defaults
  File {
    owner => $user,
    group => $group,
  }
  if ! defined(File[$basedir]) {
    file { $basedir: ensure => directory, mode => '0755' }
  } 
  if ! defined(File[$baseinstancedir]) {
    file { $baseinstancedir: ensure => directory, mode => '0755' }
  }
  if ! defined(File["${workspace}/${tarball}"]) {
    file { "${workspace}/${tarball}":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => "${filestore}/${tarball}",
      require => File[$workspace],
    }
  }
  exec { "tomcat-unpack-${instancedir}":
    cwd         => $baseinstancedir,
    command     => "/bin/tar -zxf '${workspace}/${tarball}'",
    creates     => "${baseinstancedir}/${subdir}",
    notify      => Exec["tomcat-fix-ownership-${instancedir}"],
    require     => [ File[$basedir], File[$baseinstancedir], File["${workspace}/${tarball}"] ],
  }
  exec { "tomcat-fix-ownership-${instancedir}":
    command     => "/bin/chown -R ${user}:${group} ${baseinstancedir}/${subdir}",
    refreshonly => true,
  }
  file { "${baseinstancedir}/${subdir}":
    ensure  => directory,
    require => Exec["tomcat-unpack-${instancedir}"],
  }
  file { "${baseinstancedir}/tomcat":
    ensure  => link,
    target  => $subdir,
    require => File[$baseinstancedir],
  }
  #file { "${basedir}/${subdir}/bin/thread_dump":
  #  ensure  => present,
  #  mode    => '0555',
  #  content => template('tomcat/thread_dump.erb'),
  #  require => File["${basedir}/${subdir}"],
  #}
  #file { "${basedir}/${subdir}/bin/request_processor":
  #  ensure  => present,
  #  mode    => '0555',
  #  content => template('tomcat/request_processor.erb'),
  #  require => File["${basedir}/${subdir}"],
  #}
}
