# 1. import PPA key
# 2. add ppa to sources
# 3. update APT
# 4. install apache
# 5. install php world
# 6. install mysql
# 7. install phpmyadmin

# packages definition
package { "vim":                    ensure => "installed", require => Exec['apt-update'] }
package { "apache2":                ensure => "installed", require => Exec['apt-update'] }
package { "git":                    ensure => "installed", require => Exec['apt-update'] }
package { "curl":                   ensure => "installed", require => Exec['apt-update'] }
package { "build-essential":        ensure => "installed", require => Exec['apt-update'] }
package { "php5-cli":               ensure => "installed", require => Package['apache2'] }
package { "php5-dev":               ensure => "installed", require => Package['php5-cli'] }
package { "php-pear":               ensure => "installed", require => Package['php5-cli'] }
package { "mysql-server":           ensure => "installed", require => Exec['apt-update'] }
package { "libapache2-mod-php5":    ensure => "installed", require => Package['apache2', 'php5-cli'] }
package { "php5-intl":              ensure => "installed", require => Package['libapache2-mod-php5'] }
package { "php5-curl":              ensure => "installed", require => Package['libapache2-mod-php5'] }
package { "php5-mcrypt":            ensure => "installed", require => Package['libapache2-mod-php5'] }
package { "php5-mysql":             ensure => "installed", require => Package['libapache2-mod-php5', 'mysql-server'] }
package { "php-apc":                ensure => "installed", require => Package['libapache2-mod-php5'] }
package { "php5-imagick":           ensure => "installed", require => Package['libapache2-mod-php5'] }
package { "phpmyadmin":             ensure => "installed", require => Package['php5-mysql'] }

# define apache2 service
service { "apache2":
    require => Package['apache2'],
    ensure  => "running",
    enable  => "true",
    subscribe => File[
        '/etc/apache2/sites-available/default',
        '/etc/php5/conf.d/xdebug.ini',
        '/tmp/restart.txt'
    ],
}

# set the mysql service
service { "mysql":
    require => Package['mysql-server'],
    ensure  => "running",
    enable  => "true",
    subscribe => File[
        '/tmp/restart.txt'
    ],
}

# set default vhost and reload apache2 when it's done
file { "/etc/apache2/sites-available/default":
    require => Package['apache2'],
    ensure  => "present",
    mode    => 644,
    owner   => "root",
    group   => "root",
    replace => "yes",
    content => template('apache2/default.erb'),
}

# activate mod-rewrite
file { '/etc/apache2/apache2.conf':
    require => Package['apache2'],
    ensure  => "present",
    mode    => 644,
    owner   => "root",
    group   => "root",
    replace => "yes",
    content => template('apache2/apache2.conf.erb'),
}

# php config for apache and cli
file { '/etc/php5/apache2/php.ini':
    require => Package['libapache2-mod-php5'],
    ensure  => "present",
    mode    => 644,
    owner   => "root",
    group   => "root",
    replace => "yes",
    content => template('apache2/php.ini.erb'),
}

file { '/etc/php5/cli/php.ini':
    require => Package['libapache2-mod-php5'],
    ensure  => "present",
    mode    => 644,
    owner   => "root",
    group   => "root",
    replace => "yes",
    content => template('php5/php.ini.erb'),
}

# activate mod-rewrite
file { '/etc/apache2/mods-enabled/rewrite.load':
    require => Package['apache2'],
    ensure => 'link',
    target => '/etc/apache2/mods-available/rewrite.load',
}

# enable phpmyadmin
file { '/etc/apache2/conf.d/phpmyadmin':
    require => Package['php5-mysql'],
    ensure => 'link',
    target => '/etc/phpmyadmin/apache.conf',
}

# define a file to trigger apache2 and mysql services
# each time a provisioning is launched
file { "/tmp/restart.txt":
    require => Package['apache2', 'mysql-server'],
    ensure  => "present",
    mode    => 644,
    owner   => "root",
    group   => "root",
    replace => "yes",
    content => template('apache2/restart.txt.erb'),
}

# set mysql root password
exec { "set-mysql-password":
    require => Package['mysql-server'],
    unless => "mysqladmin -uroot -proot status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password root",
}

# update and upgrade APT
exec { "apt-update":
    require => File['/etc/apt/sources.list.d/php5.list'],
    path => ["/bin", "/usr/bin"],
    command => "sudo apt-get update",
}

# install composer
exec { "install-composer":
    unless => 'ls /usr/local/bin/composer',
    require => Package['php5-cli', 'curl'],
    path => ["/bin", "/usr/bin"],
    command => "curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer && chmod 755 /usr/local/bin/composer"
}

exec { "install-xdebug":
    require => Package['build-essential', 'php5-cli'],
    unless => "ls /usr/lib/php5/20100525/xdebug.so",
    path => ["/bin", "/usr/bin"],
    command => "sudo pecl install xdebug"
}

# import the ppa key for php 5.4
exec { "add-ppa-key":
    unless => "ls /etc/apt/sources.list.d/php5.list",
    path => ["/bin", "/usr/bin"],
    command => "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C"
}

# configure xdebug
file { "/etc/php5/conf.d/xdebug.ini":
    require => Package['php5-cli'],
    ensure  => "present",
    mode    => 644,
    owner   => "root",
    group   => "root",
    replace => "yes",
    content => template('php5/xdebug.ini.erb'),
}

# install deb source for php5.4
file { "/etc/apt/sources.list.d/php5.list":
    require => Exec['add-ppa-key'],
    ensure  => "present",
    mode    => 644,
    owner   => "root",
    group   => "root",
    replace => "yes",
    content => template('apt/php5.list.erb'),
}
