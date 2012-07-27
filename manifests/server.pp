# == Definition: bind::server
#
# Defines characteristics to be associated with a remote nameserver
#
# Parameters:
# * *name*: IP address of the server to be defined.
# * *order*: The order or priority of this directive. Default: 50
# * *bogus*: If you discover that a remote server is giving out bad data,
#   marking it as bogus will prevent further queries to it. Default: "no"
# * *provide_ixfr*: determines whether the local server, acting as master,
#   will respond with an incremental zone transfer when the given remote
#   server, a slave, requests it.
# * *request_ixfr*: determines whether the local server, acting as a slave,
#   will request incremental zone transfers from the given remote server, a
#   master
# * *edns*: determines whether the local server will attempt to use EDNS when
#   communicating with the remote server. Default: "yes"
# * *transfers*: used to limit the number of concurrent inbound zone transfers
#   from the specified server
# * *transfer_format*:
#   * *one-answer*: uses one DNS message per resource record transferred
#   * *many-answers*: packs as many resource records as possible into a message
# * *keys*: identify a key_id defined by the key statement, to be used for
#   transaction security when talking to the remote server
#
# Examples:
#
#    bind::server { "192.168.1.1":
#        keys => "example.com.",
#    }
#
define bind::server (
    $order = "50",
    $bogus = "no",
    $provide_ixfr = "",
    $request_ixfr = "",
    $edns = "yes",
    $transfers = "",
    $transfer_format = "",
    $keys = ""
) {

    concatfile::part { "/etc/named.conf.d/${order}_server_${name}":
        content => template("bind/server.erb")
    }

}
