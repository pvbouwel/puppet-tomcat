define tomcat::service (
  $instancename,
  $java_home,
  $product_dir,
  $templates,
  $user,
) {
  if ! $templates['servicescript.sh'] {
    file { "/etc/init.d/tomcat_${instancename}.sh":
      ensure   => present,
      content  => template('tomcat/servicescript.sh.erb'),
      mode   => '0755',
    }
  } else {
    file { "/etc/init.d/tomcat_${instancename}.sh":
      ensure   => present,
      content  => template($templates['servicescript.sh']),
      mode   => '0755',
    }
  }

}
