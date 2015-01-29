define tomcat::install (
  $basedir,
  $filestore,
  $group,
  $java_home,
  $logdir,
  $instancename,
  $instancedir,
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
  #if ! defined(File[$basedir]) {
  #  file { $basedir: ensure => directory, mode => '0755' }
  #} 
  if ! defined(File[$instancedir]) {
    file { $instancedir: ensure => directory, mode => '0755' }
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
  exec { "tomcat-unpack-${instancename}":
    cwd         => $instancedir,
    command     => "/bin/tar -zxf '${workspace}/${tarball}'",
    creates     => "${instancedir}/${subdir}",
    notify      => Exec["tomcat-fix-ownership-${instancename}"],
    require     => [ File[$basedir], File["${instancedir}"], File["${workspace}/${tarball}"] ],
  }
  exec { "tomcat-fix-ownership-${instancename}":
    command     => "/bin/chown -R ${user}:${group} ${instancedir}/${subdir}",
    refreshonly => true,
  }
  file { "${instancedir}/${subdir}":
    ensure  => directory,
    require => Exec["tomcat-unpack-${instancename}"],
  }
  file { "${instancedir}/tomcat":
    ensure  => link,
    target  => $subdir,
    require => File[$instancedir],
  }
}
