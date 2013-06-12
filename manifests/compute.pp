class vem::compute(
    $vemimage,
    $vsmip,
    $domainid,
    $ctrlmac,
    $hostmgmtint,
    $uplinkint,
    $uvembrname = "n1kvdvs" )
{

  $b = inline_template('<%= File.basename(vemimage) %>')
  $imgfile = "/etc/n1kv/$b"
  $generate_output = generate("/usr/bin/sudo", "/bin/cp", "$vemimage", "/etc/puppet/files/$b")

  package { "libnl1":
         ensure => installed
  }

  file { '/etc/n1kv':
         owner => 'root',
         group => 'root',
         mode  => '664',
         ensure => directory,
         require => Package['libnl1']
  }

  file { $imgfile:
         owner => 'root',
         group => 'root',
         mode => '666',
         source => "puppet:///files/$b",
         require => File['/etc/n1kv']
  }

  package {"nexus100v":
        provider => dpkg,
        ensure => installed,
        source => $imgfile,
        require => File[$imgfile]
  }

  file {"/etc/n1kv/n1kv.conf":
        owner => 'root',
        group => 'root',
        mode => '666',
        content => template('vem/n1kv.conf.erb')
  }

  exec {"launch_vem":
       command => "/usr/sbin/service n1kv start",
       unless => "/sbin/vemcmd show card"
  }
  
  File['/etc/n1kv/n1kv.conf'] -> Exec['launch_vem']

}
