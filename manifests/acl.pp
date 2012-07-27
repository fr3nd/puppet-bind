# == Definition: bind::acl
#
# Define a group of hosts, so that they can be permitted or denied access to
# the nameserver
#
# Parameters:
# * *name*: The name of the access control list
# * *order*: The order or priority of this directive. Default: 50
# * *sources*: usually an individual IP address (such as 10.0.1.1) or a CIDR
#   network notation (for example, 10.0.1.0/24). There are some predefined
#   keywords: any (every IP address), localhost (any IP address that is in use
#   by the local system), localnets (any IP address on any network to which the
#   local system is connected), none (Does not match any IP address)
#
# Examples:
#
#    bind::acl { "intranet":
#        sources => [
#                    "192.168.0.0/16",
#                    "172.20.4.0/24",
#                   ]
#    }
#
define bind::acl (
    $order = "50",
    $sources = [ ]
) {

    concatfile::part { "/etc/named.conf.d/${order}_acl_${name}":
        content => template("bind/acl.erb")
    }

}
