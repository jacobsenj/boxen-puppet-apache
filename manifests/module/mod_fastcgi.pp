class apache::module::mod_fastcgi {
  include apache::module::requirements

  $version = '2.4.7-boxen1'

  homebrew::formula { 'mod_fastcgi':
    before => Package['boxen/brews/mod_fastcgi'],
  }

  package { 'boxen/brews/mod_fastcgi':
    ensure => $version,
    require => Class['Apache::module::requirements'],
    install_options => [
      '--with-osx-httpd24'
    ]
  }

  file { '/etc/apache2/other/00-mod_fastcgi.conf':
    ensure  => present,
    content => template('apache/config/apache/modules/mod_fastcgi.conf.erb'),
  }
}
