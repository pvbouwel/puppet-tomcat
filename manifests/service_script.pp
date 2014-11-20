define tomcat::service_script (
  $ensure = present,
  $instancename,
  $java_home,
  $product_dir,
  $templates,
  $user,
) {
   
  if ! $templates['servicescript.sh'] {
    $servicescript_content = template('tomcat/servicescript.sh.erb')
  } else {
    $servicescript_content = template($templates['servicescript.sh'])
  }
  if $ensure == present {
   file{ "/etc/init.d/tomcat_${instancename}.sh":
     ensure   => present,
     content  => $servicescript_content,
     mode   => '0755',
   }
   service{ "tomcat_${instancename}.sh":
     ensure => running,
     enable => true,
     require => File["/etc/init.d/tomcat_${instancename}.sh"]
   }
  }else {
    if $ensure == present {
	    file{ "/etc/init.d/tomcat_${instancename}.sh":
	      ensure   => absent,
	      content  => $servicescript_content,
	      mode   => '0755',
	      require => Service["tomcat_${instancename}.sh"]
	    }

	    service{ "tomcat_${instancename}.sh":
	      ensure => stopped,
	      enable => true,
	    }
    }
  }
}
