# == Class: bind
#
# Main module class. It will install the necesary packages and create all the
# required directories
#
# http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/s1-BIND.html
#
# http://www.net.cmu.edu/groups/netdev/docs/bind9/Bv9ARM.ch06.html
# http://centos.org/docs/2/rhl-rg-en-7.2/s1-bind-configuration.html
#
# Parameters:
# * purge: set to false if you don't want to purge all non-defined dns entries
#
class bind (
    $purge = true
) {
    package { "bind-chroot":
        ensure => installed,
    }

    service { "named":
        ensure     => running,
        enable     => true,
        require    => Package["bind-chroot"],
        hasrestart => true,
        hasstatus  => true,
        restart    => "/sbin/service named force-reload",
        subscribe  => Concatfile["/etc/named.conf"],
    }

    file {
        "/etc/named/views.d":
            require => Package["bind-chroot"],
            owner   => "root",
            group   => "root",
            purge   => $purge,
            recurse => true,
            force   => true,
            ensure  => directory;
        "/etc/named/zones":
            require => Package["bind-chroot"],
            owner   => "root",
            group   => "root",
            purge   => $purge,
            recurse => true,
            force   => true,
            ensure  => directory;
        '/var/named/slaves':
            require => Package["bind-chroot"],
            owner   => "named",
            group   => "named",
            ensure  => directory;
        '/var/named/data':
            require => Package["bind-chroot"],
            owner   => "named",
            group   => "named",
            ensure  => directory;
        "/var/named/slaves/_common_":
            require => Package["bind-chroot"],
            owner   => "named",
            group   => "named",
            ensure  => directory;
        "/etc/named/zones/_common_":
            require => Package["bind-chroot"],
            owner   => "root",
            group   => "root",
            purge   => $purge,
            recurse => true,
            force   => true,
            ensure  => directory;
        '/etc/rndc.key':
            owner   => 'root',
            group   => 'named',
            mode    => '0640',
            require => Exec['generate_rndc.key'],
            notify  => Service['named'];
    }

    exec {
        'restart_named':
            command     => '/sbin/service named try-restart',
            refreshonly => true;
        'generate_rndc.key':
            command => '/usr/sbin/rndc-confgen -a',
            creates => '/etc/rndc.key',
            require => Package['bind-chroot'],
    }

    concatfile { "/etc/named.conf":
        require => Package["bind-chroot"],
        dir     => "/etc/named.conf.d",
        owner   => "named",
        group   => "named",
    }
}
