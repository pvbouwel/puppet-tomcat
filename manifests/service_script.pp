define tomcat::service_script (
  $ensure       = present,
  $instancename = undef,
  $java_home    = undef,
  $product_dir  = undef,
  $templates    = undef,
  $user         = undef,
) {
   
  if ! $templates['servicescript.sh'] {
    $servicescript_content = template('tomcat/servicescript.sh.erb')
  } else {
    $servicescript_content = template($templates['servicescript.sh'])
  }
  
  if $ensure == present {
   file{ "/etc/init.d/tomcat_${instancename}.sh":
     ensure  => present,
     content => $servicescript_content,
     mode    => '0755',
   }
   service{ "tomcat_${instancename}.sh":
     name      => "tomcat_${instancename}.sh",
     ensure    => running,
     enable    => true,
     hasstatus => true,
     require   => File["/etc/init.d/tomcat_${instancename}.sh"]
   }
  }else {  
    file{ "/etc/init.d/tomcat_${instancename}.sh":
      ensure  => absent,
      content => $servicescript_content,
      mode    => '0755',
      require => Service["tomcat_${instancename}.sh"]
    }

    service{ "tomcat_${instancename}.sh":
      name      => "tomcat_${instancename}.sh",
      hasstatus => true,
      ensure    => stopped,
      enable    => true,
    }
  }
}
