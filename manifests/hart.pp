# packages definition
package { "vim": ensure => "installed" }
package { "apache2": ensure => "installed" }
package { "curl": ensure => "installed" }
package { "build-essential": ensure => "installed" }
package { "php5-cli": ensure => "installed" }
package { "php5-dev": ensure => "installed", require => Package['libapache2-mod-php5', 'php5-cli'] }
package { "php-pear": ensure => "installed", require => Package['php5-cli'] }
package { "mysql-server": ensure => "installed", require => Exec['apt-update'] }
package { "libapache2-mod-php5": ensure => "installed", require => Package['apache2', 'php5-cli'] }
package { "php5-intl": ensure => "installed", require => Package['libapache2-mod-php5'] }
package { "php5-curl": ensure => "installed", require => Package['libapache2-mod-php5'] }
package { "php5-mcrypt": ensure => "installed", require => Package['libapache2-mod-php5'] }
package { "php5-mysql": ensure => "installed", require => Package['libapache2-mod-php5'] }
package { "php-apc": ensure => "installed", require => Package['libapache2-mod-php5'] }
package { "php5-imagick": ensure => "installed", require => Package['libapache2-mod-php5'] }
package { "phpmyadmin": ensure => "installed", require => Package['libapache2-mod-php5'] }

# define apache2 service
service { "apache2":
    ensure  => "running",
    enable  => "true",
    require => Package["apache2"],
    subscribe => File[
        '/etc/apache2/sites-available/default',
        '/etc/php5/conf.d/xdebug.ini',
        '/tmp/restart.txt'
    ]
}

# set the mysql service
service { "mysql":
    ensure  => "running",
    enable  => "true",
    require => Package["mysql-server"],
    subscribe => File[
        '/tmp/restart.txt'
    ]
}

# set default vhost and reload apache2 when it's done
file { "/etc/apache2/sites-available/default":
    require => Package["apache2"],
    ensure  => "present",
    mode    => 644,
    owner   => "root",
    group   => "root",
    replace => "yes",
    content => template('apache2/default.erb'),
}

# activate mod-rewrite
file { '/etc/apache2/mods-enabled/rewrite.load':
    ensure => 'link',
    target => '/etc/apache2/mods-available/rewrite.load',
    require => Package['apache2']
}

# enable phpmyadmin
file { '/etc/apache2/conf.d/phpmyadmin':
    ensure => 'link',
    target => '/etc/phpmyadmin/apache.conf',
    require => Package['apache2', 'libapache2-mod-php5', 'mysql-server']
}

# define a file to trigger apache2 and mysql services
# each time a provisioning is launched
file { "/tmp/restart.txt":
    require => Package["apache2", "mysql-server"],
    ensure  => "present",
    mode    => 644,
    owner   => "root",
    group   => "root",
    replace => "yes",
    content => template('apache2/restart.txt.erb'),
}

# set mysql root password
exec { "set-mysql-password":
    unless => "mysqladmin -uroot -proot status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password root",
    require => Service["mysql"],
}

# update and upgrade APT
exec { "apt-update":
    path => ["/bin", "/usr/bin"],
    command => "sudo apt-get update",
}

# install composer
exec { "install-composer":
    require => Package['php5-cli', 'curl'],
    path => ["/bin", "/usr/bin"],
    command => "curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer && chmod 755 /usr/local/bin/composer"
}

exec { "install-xdebug":
    unless => "ls /usr/lib/php5/20090626/xdebug.so",
    require => Package['build-essential', 'php-pear', 'php5-dev'],
    path => ["/bin", "/usr/bin"],
    command => "sudo pecl install xdebug"
}

# configure xdebug
file { "/etc/php5/conf.d/xdebug.ini":
    require => Exec["install-xdebug"],
    ensure  => "present",
    mode    => 644,
    owner   => "root",
    group   => "root",
    replace => "yes",
    content => template('php5/xdebug.ini.erb'),
}
