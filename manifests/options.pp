# == Class: bind::options
#
# Define global server configuration options as well as to set defaults for
# other statements. It can be used to specify the location of the named
# working directory, the types of queries allowed, and much more
#
# Parameters:
# * *order*: The order or priority of this directive. Default: 50
# * *version*: The version the server should report via a query of name
#    version.bind in class CHAOS. The default is the real version number of
#    this server
# * *directory*: Specifies a working directory for the named service. Default:
#   "/var/named"
# * *dump_file*: The pathname of the file the server dumps the database to when
#   instructed to do so with rndc dumpdb. Default: "data/cache_dump.db"
# * *statistics_file*: The pathname of the file the server appends statistics to
#   when instructed to do so using rndc stats. Default: "data/named_stats.txt"
# * *memstatistics_file*: The pathname of the file the server writes memory usage
#   statistics to on exit. Default: "data/named_mem_stats.txt"
# * *listen_on_port*: Specifies the IPv4 port on which to listen for queries.
#   Default: "53"
# * *listen_on*: Array which specifies the IPv4 network interface on which to
#   listen for queries. Default: "127.0.0.1"
# * *listen_on_v6_port*: Specifies the IPv6 port on which to listen for queries.
#   Default: "53"
# * *listen_on_v6*: Array which specifies the IPv6 network interface on which to
#   listen for queries. Default: "::1"
# * *allow_query*: Array which specifies which hosts are allowed to query the
#   nameserver for authoritative resource records. It accepts an access control
#   lists, a collection of IP addresses, or networks in the CIDR notation.
#   Default: "any"
# * *allow_query_cache*: Array which specifies which hosts are allowed to query
#   the nameserver for non-authoritative data such as recursive queries.
#   Default: [ "localhost", "localnets" ]
# * *allow_transfer*: Array which specifies which hosts are allowed to receive
#   zone transfers from the server. Default: "none"
# * *recursion*: Specifies whether to act as a recursive server. Deefault: "yes"
# * *bind_notify*: Specifies whether to notify the secondary nameservers when a
#   zone is updated. Default: "yes". It accepts the following options:
#   * *yes*: The server will notify all secondary nameservers.
#   * *no*: The server will not notify any secondary nameserver.
#   * *master-only*: The server will notify primary server for the zone only.
#   * *explicit*: The server will notify only the secondary servers that are
#     specified in the also-notify list within a zone statement.
# * *dnssec_enable*: Specifies whether to return DNSSEC related resource
#   records. Default: "yes"
# * *dnssec_validation*: Specifies whether to prove that resource records are
#   authentic via DNSSEC. Default: "yes"
# * *dnssec_lookaside*: Default: "auto"
# * *blackhole*: Specifies which hosts are not allowed to query the nameserver.
#   This option should be used when particular host or network floods the
#   server with requests. Default: [ ]
# * *forwarders*: Specifies a list of valid IP addresses for nameservers to
#   which the requests should be forwarded for resolution. Default: []
# * *forward*: Specifies the behavior of the forwarders directive. Default: ""
#   It accepts following options:
#   * *first*: The server will query the nameservers listed in the forwarders
#     directive before attempting to resolve the name on its own
#   * *only*: When unable to query the nameservers listed in the forwarders
#     directive, the server will not attempt to resolve the name on its own
# * *max_cache_size*: Specifies the maximum amount of memory to be used for
#   server caches. When the limit is reached, the server causes records to
#   expire prematurely so that the limit is not exceeded. In a server with
#   multiple views, the limit applies separately to the cache of each view.
#   Default: "32M"
#
# Examples:
#
#   include bind::options
#
class bind::options (
    $order = "50",
    $version = "",
    $directory = "/var/named",
    $dump_file = "data/cache_dump.db",
    $statistics_file = "/var/named/data/named_stats.txt",
    $memstatistics_file = "/var/named/data/named_mem_stats.txt",
    $listen_on_port = "53",
    $listen_on = [ "127.0.0.1" ],
    $listen_on_v6_port = "53",
    $listen_on_v6 = [ "::1" ],
    $allow_query = [ "any" ],
    $allow_query_cache = [ "localhost", "localnets" ],
    $allow_transfer = [ "none" ],
    $allow_update = undef,
    $recursion = "yes",
    $bind_notify = "yes",
    $dnssec_enable = "yes",
    $dnssec_validation = "yes",
    $dnssec_lookaside = "auto",
    $blackhole = [ ],
    $forwarders = [],
    $forward = "",
    $max_cache_size = "32M"
) {

    concatfile::part { "/etc/named.conf.d/${order}_options":
        content => template("bind/options.erb")
    }

}
