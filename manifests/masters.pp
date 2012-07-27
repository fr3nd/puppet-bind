# == Definition: bind::masters
#
# Define a group of masters, so that they can be used in slave zones
#
# Parameters:
# * *name*: Name of the list
# * *order*: The order or priority of this directive. Default: 50
# * *sources*: Array with the IP addresses of the masters in the list
#
# Examples:
#
#    bind::masters { "main_dns_servers":
#        sources => [
#                    "192.168.1.1",
#                    "192.168.1.2",
#                   ]
#    }
#
define bind::masters (
    $order = "50",
    $sources = [ ]
) {

    concatfile::part { "/etc/named.conf.d/${order}_masters_${name}":
        content => template("bind/masters.erb")
    }

}
