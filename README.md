The goal is to have a puppet module that is able to install tomcat in its
basic form.  So to remove the dependency from runit.  Additionally we want
to support multiple versions on 1, for this each tomcat instance will have
its own full blown home directory.  Also it would be nice to have the
possibility to configure the ports so that multiple instance can run
simultaneously. I'd like to build on this project because I like the idea
of using the tarballs to create a setup.

# puppet-tomcat

Puppet module to install Apache Tomcat and run instances as Runit services
under one or more users.

The recommended usage is to place the configuration in hiera and just:

    include tomcat

Example hiera config is included in the root of the repository.

If you use the puppet filestore, don't forget to stage your tarballs. The
default tomcat naming scheme is used for the filenames.



## tomcat parameters

*basedir*: The base installation directory. Default: '/opt/tomcat' this 
directory will hold the extracted tarball.

*bind_address*: The IP or hostname to bind listen ports to. Default: $fqdn

*check_port*: The port that the instance must be listening on (bound to
bind_address) for it to be considered up. Default: '8080'

*config*: A hash of additional configuration variables that will be set when
templates are processed.

*dependencies*: A list of Runit service directories whose services must be up
before the Tomcat service is started.

*cpu_affinity*: Enable CPU affinity to be set to only run processes on specific
CPU cores - for example '0,1' to only run processes on the first two cores.

*files*: A hash of configuration files to install - see below

*filestore*: The Puppet filestore location where the Tomcat tarball and Jolokia
war file are downloaded from. Default: 'puppet:///files/tomcat'

*gclog_enabled*:  Whether or not Garbage Collector logging is enabled. Default:
'false'

*gclog_numfiles*: The number of garbage collector log files to keep. Default:
'5'

*gclog_filesize*: The maximum size of a garbage collector log file before it is
rotated. Default: '100M'

*group*: The user''s primary group. Default: 'tomcat',

*java_home*: The base directory of the JDK installation to be used. Default:
'/usr/java/latest'

*java_opts*: Additional java command-line options to pass to the startup script

*jolokia*: Whether or not to install the jolokia war file and configure a
separate service to run it. Default: false

*jolokia_address*: The address that the jolokia HTTP service listens on.
Default: 'localhost'

*jolokia_cron*: Whether or not to install cron jobs to run the Jolokia JMX
monitoring scripts every minute writing to local log files. Default: 'true'

*jolokia_port*: The port that the jolokia HTTP service listens on. Default:
'8190'

*jolokia_version*: The version of the jolokia war file to download and install.
Default: '1.1.1'

*localhost*: The localhost address to bind listen ports to. Default: 'localhost'

*logdir*: The base log directory. Default: '/var/logs/tomcat'

*min_mem*: The minimum heap size allocated by the JVM. Default: 1024m

*max_mem*: The maximum heap size allocated by the JVM. Default: 2048m

*mode*: The permissions to create files with (eg. 0444).

*remove_docs*: Whether or not to remove the Tomcat docs under webapps. Default: true

*remove_examples*: Whether or not to remove the Tomcat examples under webapps. Default: true

*templates*: A hash of templates. if an entry is placed for one of the templates, the passed 
template is used instead of the template supplied in modules. Each template in the templates
directory can be replaced by creating an entry for the name. 

*ulimit_nofile*: The maximum number of open file descriptors the java process
is allowed.  Default is '$(ulimit -H -n)' which sets the value to the hard
limit in /etc/security/limits.conf (or equivalent) for the user.

*version*: The version of the product to install (eg. 7.0.37). **Required**.

*workspace*: A temporary directory to unpack install tarballs into. Default:
'/root/tomcat'

## tomcat::instance parameters

*title*: The user the Tomcat instance runs as

Plus all of the parameters specified in 'tomcat parameters' above

## Config files

Files or templates for each of the Tomcat instances can be delivered via
Puppet.  The former are delivered as-is while the latter are processed as ERB
templates before being delivered.

For example configuration could be delivered using for instances running as the
tomcat1 and tomcat2 users with:

    tomcat::config:
      admin_user: 'admin'
      admin_pass: 'admin'

    tomcat::files:
      conf/tomcat-users.xml:
        source: 'puppet:///files/tomcat/dev/context.xml'
      
    tomcat:
      tomcat1:
        config:
          admin_pass: 'tinstaafl'
        templates:
          conf/tomcat-users.xml:
            template: '/etc/puppet/templates/tomcat/dev1/tomcat-users.xml.erb'
      tomcat2:
        config:
          admin_pass: 'timtowtdi'
        templates:
          conf/tomcat-users.xml:
            template: '/etc/puppet/templates/tomcat/dev2/tomcat-users.xml.erb'

Values set at the tomcat level as set for all instances so both the tomcat1 and
tomcat2 instance would get the same context.xml file.  Each instance would get
their own tomcat-users.xml file based on the template specified with instance
variables (like basedir and logdir) and config variables (like admin_user and
admin_pass above) substituted.

For example:

    <user username="<%= @admin_user %>"
          password="<%= @admin_pass %>"
          roles="tomcat,manager-gui"/>

All files and templates are relative to the product installation.  For example
if the product installation is '/opt/tomcat/apache-tomcat-7.0.37' then the full
path to the 'tomcat-users.xml' file would be
'/opt/tomcat/apache-tomcat-7.0.37/conf/tomcat-users.xml'.

Note that the path specified by the 'template' parameter is on the Puppet
master.

## Default templates

There are default templates for conf/server.xml to listen on the specified
bind_address and for conf/logging.properties to use the specified logdir.
These defaults are only used if the template is not specified using the
templates configuration.

## Product files

By default the product tar file (eg. 'apache-tomcat-7.0.55.tar.gz') is expected
to be found under a 'tomcat' directory of the 'files' file store.  For example
if /etc/puppet/fileserver.conf has:

    [files]
    path /var/lib/puppet/files

then put the tar file in /var/lib/puppet/files/tomcat.  Any files specified
with the 'files' parameter can also be placed in this directory.

This location can be changed by setting the 'filestore' parameter.

# Facts
This module will create a fact called tomcat_instances that will report on the
provided instances.  

# Support

License: Apache License, Version 2.0

GitHub URL: https://github.com/pvbouwel/puppet-tomcat
forked from: https://github.com/erwbgy/puppet-tomcat
