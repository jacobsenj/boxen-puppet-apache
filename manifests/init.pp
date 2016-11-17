class apache {
  require apache::config
  require homebrew

  file { '/Library/LaunchDaemons/dev.httpd.plist':
    content => template('apache/dev.httpd.plist.erb'),
    group   => 'wheel',
    notify  => Service['dev.httpd'],
    owner   => 'root'
  }

  # Add all the directories and files Apache is expecting
  # Most of these should already exist on Mountain Lion
  file { [
    $apache::config::configdir,
    $apache::config::logdir,
    $apache::config::sitesdir,
    $apache::config::portdir,
    "${apache::config::configdir}/other",
  ]:
    ensure => directory
  }

  file { $apache::config::configfile:
    content => template('apache/config/apache/httpd.conf.erb'),
    notify  => Service['dev.httpd']
  }

  service { "dev.httpd":
    ensure  => running,
    enable => true,
    require => Package['homebrew/apache/httpd24'],
  }

  service { "org.apache.httpd":
    before => Service['dev.httpd'],
    ensure => stopped,
  }

  service { "homebrew.mxcl.httpd24":
    before => Service['dev.httpd'],
    ensure => stopped,
    enable => false,
  }

}
