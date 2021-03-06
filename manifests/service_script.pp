# Define: tomcat::service_script
#
# This define initializes the init script
define tomcat::service_script (
  $ensure       = present,
  $instancename = undef,
  $instance_dir = undef,
  $java_home    = undef,
  $product_dir  = undef,
  $templates    = undef,
  $user         = undef
) {

  if ! $templates['servicescript.sh'] {
    $servicescript_content = template('tomcat/servicescript.sh.erb')
  } else {
    $servicescript_content = template($templates['servicescript.sh'])
  }

  if $ensure == 'present' or $ensure == 'running' {
    file{ "/etc/init.d/tomcat_${instancename}.sh":
      ensure  => 'present',
      content => $servicescript_content,
      mode    => '0755',
  }
  if $ensure == 'running' {
    service{ "tomcat_${instancename}.sh":
      ensure    => 'running',
      name      => "tomcat_${instancename}.sh",
      enable    => true,
      hasstatus => true,
      require   => File["/etc/init.d/tomcat_${instancename}.sh"]
    }
  } else {
    service{ "tomcat_${instancename}.sh":
      name      => "tomcat_${instancename}.sh",
      enable    => true,
      hasstatus => true,
      require   => File["/etc/init.d/tomcat_${instancename}.sh"]
    }
  }
  }else {
    file{ "/etc/init.d/tomcat_${instancename}.sh":
      ensure  => 'absent',
      content => $servicescript_content,
      mode    => '0755',
      require => Service["tomcat_${instancename}.sh"]
    }

    service{ "tomcat_${instancename}.sh":
      ensure    => 'stopped',
      name      => "tomcat_${instancename}.sh",
      hasstatus => true,
      enable    => true,
    }
  }
}
