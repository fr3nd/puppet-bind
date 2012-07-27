# == Definition: bind::view
#
# Allows you to create special views depending upon which network the host
# querying the nameserver is on. This allows some hosts to receive one answer
# regarding a zone while other hosts receive totally different information
#
# Parameters:
# * *name*: Name of the view to be defined
# * *order*: The order or priority of this directive. Default: 50
# * *match_clients*: Array to specify the IP addresses that apply to a
#   particular view
# * *match_destinations*:
# * *match_recursive_only*: Default: "no"
#
# Notes:
#
# Due to a limitation on how the views are created and how the zones in all
# views are managed, it's currently not possible to remove a view using puppet.
# Instead, it should be removed manually from the server first and then from
# the puppet manifests
#
# Examples:
#
#    bind::view { "gb_and_ireland":
#        match_clients => [ "GB", "IE" ],
#    }
#
define bind::view (
    $order = "50",
    $match_clients = [ ],
    $match_destinations = [ ],
    $match_recursive_only = "no"
) {

    file {
        "/etc/named/zones/${name}":
            ensure  => directory,
            purge   => $::bind::purge,
            recurse => true,
            force   => true;
        "/var/named/slaves/${name}":
            owner   => 'named',
            group   => 'named',
            ensure  => directory,
    }

    concatfile::part { "/etc/named.conf.d/${order}_view_${name}":
        file => "/etc/named/views.d/${name}.view",
    }

    concatfile { "/etc/named/views.d/${name}.view":
        dir    => "/etc/named/views.d/${name}.d",
        notify => [ Service["named"], Concatfile["/etc/named.conf"] ],
    }

    concatfile::part { "/etc/named/views.d/${name}.d/00_header":
        content => template("bind/view_header.erb")
    }
    concatfile::part { "/etc/named/views.d/${name}.d/99_footer":
        content => template("bind/view_footer.erb")
    }
}
