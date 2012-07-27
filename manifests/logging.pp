# == Class: bind::logging
#
# Class to configure logging. It will create the main scheleton to configure channels
# and categories
#
# Parameters:
# * *order*: The order or priority of this directive. Default: 50
#
class bind::logging (
    $order = "50"
) {

    file { "/etc/named/logging.d":
        require => Package["bind-chroot"],
        owner   => "root",
        group   => "root",
        purge   => $::bind::purge,
        recurse => true,
        force   => true,
        ensure  => directory;
    }

    concatfile::part { "/etc/named.conf.d/${order}_logging":
        file => "/etc/named/logging.d/logging",
    }

    concatfile { "/etc/named/logging.d/logging":
        dir    => "/etc/named/logging.d/logging.d",
        notify => [ Service["named"], Concatfile["/etc/named.conf"] ],
    }

    concatfile::part { "/etc/named/logging.d/logging.d/00_header":
        content => template("bind/logging_header.erb")
    }
    concatfile::part { "/etc/named/logging.d/logging.d/99_footer":
        content => template("bind/logging_footer.erb")
    }

}
