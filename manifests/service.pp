define tomcat::service (
  $ensure = present,
  $instancename,
  $java_home,
  $product_dir,
  $templates,
  $user,
) {
  
  $tomcat_service_ensure = $ensure
  if $tomcat_service_ensure == present {
    $tomcat_service_status = running
  } else {
    $tomcat_service_status = stopped
    $tomcat_service_ensure = absent
  }
  
  
  
  if ! $templates['servicescript.sh'] {
    $servicescript_content = template('tomcat/servicescript.sh.erb')
  } else {
    $servicescript_content = template($templates['servicescript.sh'])
  }
  
  file{ "/etc/init.d/tomcat_${instancename}.sh":
    ensure   => $tomcat_service_ensure,
    content  => $servicescript_content,
    mode   => '0755',
  }
  service{ "tomcat_${instancename}.sh":
    ensure => $tomcat_service_status,
    enable => true,
    require => [ File["${product_dir}/conf/server.xml"], 
                 File["${product_dir}/bin/startup.sh"], 
                 File["${product_dir}/conf/logging.properties"], 
                 File["/etc/init.d/tomcat_${instancename}.sh"] ]
  }
}
