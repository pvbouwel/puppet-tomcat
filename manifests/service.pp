define tomcat::service (
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
  
  file{ "/etc/init.d/tomcat_${instancename}.sh":
    ensure   => present,
    content  => $servicescript_content,
    mode   => '0755',
  }-> 
  service{ "tomcat_${instancename}.sh":
    ensure => running,
    enable => true,
    require => [ File["${product_dir}/conf/server.xml"], 
                 File["${product_dir}/bin/startup.sh"], 
                 File["${product_dir}/conf/logging.properties"], 
                 File["/etc/init.d/tomcat_${instancename}.sh"] ]
  }
}
