# == Definition: bind::key
#
# Define a particular key by name. Keys are used to authenticate various
# actions, such as secure updates or the use of the rndc command
#
# Parameters:
# * *name*: Name of the key to be defined
# * *order*: The order or priority of this directive. Default: 50
# * *algorithm*: The type of algorithm to be used. Default: hmac-md5
# * *secret*: The encrypted key
#
# Examples:
#
#  bind::key { "example.com.":
#      algorithm => "hmac-md5",
#      secret    => "IIVj/9sByAO0OzeYuBNKC==",
#  }
#
define bind::key (
    $order = "50",
    $algorithm = "hmac-md5",
    $secret = ""
) {

    concatfile::part { "/etc/named.conf.d/${order}_key_${name}":
        content => template("bind/key.erb")
    }

}
