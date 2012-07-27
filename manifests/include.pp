# == Definition: bind::include
#
# Includes an external file in named.conf
#
# Parameters:
# * *name*: The path of the file to be included
# * *order*: The order or priority of this directive. Default: 50
#
# Examples:
#
#   bind::include { "/etc/named.rfc1912.zones": }
#
define bind::include (
    $order = "50"
) {

    $safe_name = gsub($name,"/","_")

    concatfile::part { "/etc/named.conf.d/${order}_include_${safe_name}":
        require => File["/etc/named.conf.d"],
        content => "include \"${name}\";\n\n",
    }

}
