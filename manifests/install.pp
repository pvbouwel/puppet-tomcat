define tomcat::install (
  $basedir,
  $filestore,
  $group,
  $java_home,
  $logdir,
  $ulimit_nofile,
  $user,
  $version,
  $workspace,
) {
  $tarball = "apache-tomcat-${version}.tar.gz"
  $subdir  = "apache-tomcat-${version}"
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
  exec { "tomcat-unpack-${user}":
    cwd         => $basedir,
    command     => "/bin/tar -zxf '${workspace}/${tarball}'",
    creates     => "${basedir}/${subdir}",
    notify      => Exec["tomcat-fix-ownership-${user}"],
    require     => [ File[$basedir], File["${workspace}/${tarball}"] ],
  }
  exec { "tomcat-fix-ownership-${user}":
    command     => "/bin/chown -R ${user}:${group} ${basedir}/${subdir}",
    refreshonly => true,
  }
  file { "${basedir}/${subdir}":
    ensure  => directory,
    require => Exec["tomcat-unpack-${user}"],
  }
  file { "${basedir}/tomcat":
    ensure  => link,
    target  => $subdir,
    require => File[$basedir],
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
