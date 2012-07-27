# == Definition: bind::zone
#
# Create a new zone. This zone can be a "regular" zone or inside an already
# defined view. To create a "regular" zone, just use the zone name as the
# name. If this zone will be inside one specific view, use the format
# "view/zone". If you want to place this zone inside all the defined views
# use the format "*/zone"
#
# Parameters:
# * *name*: Name of the zone. There are three kinds of zones that can be
#   created:
#   * *regular zone*: Format: "zone"
#   * *zone inside a view*: Format: "view/zone"
#   * *zone inside all views*: Format: "*/zone"
# * *order*: The order or priority of this directive. Default: 50
# * *zone_type*: Specifies the zone type. It accepts the following options:
#   * *delegation-only*: Enforces the delegation status of infrastructure
#     zones such as COM, NET, or ORG.
#   * *forward*: Forwards all requests for information about this zone to
#     other nameservers
#   * *hint*: A special type of zone used to point to the root nameservers
#     which resolve queries when a zone is not otherwise known. No
#     configuration beyond the default is necessary with a hint zone
#   * *master*: Designates the nameserver as authoritative for this zone. A
#     zone should be set as the master if the zone's configuration files
#     reside on the system
#   * *slave*: Designates the nameserver as a slave server for this zone.
#     Master server is specified in masters directive.
# * *allow_notify*:
# * *allow_query*: Array which specifies which clients are allowed to
#   request information about this zone
# * *allow_transfer*: Array which specifies which secondary servers are
#   allowed to request a transfer of the zone's information
# * *allow_update*: Array which specifies which hosts are allowed to
#   dynamically update information in their zone
# * *masters*: Array which specifies from which IP addresses to request
#   authoritative zone information. This option is used only if the zone is
#   defined as type slave.
# * *zone_statistics*:
# * *also_notify*:
# * *zone_ttl*: SOA time-to-retry directive
# * *zone_soa*: SOA primary-name-server
# * *zone_soa_email*: SOA email
# * *zone_refresh*: SOA time-to-refresh directive
# * *zone_retry*: SOA time-to-retry directive
# * *zone_expire*: SOA time-to-expire directive
# * *zone_minimum*: SOA minimum-TTL
# * *zone_ns*: Array with the nameservers for this zone
#
# Examples:
#
# bind::zone { "test.com":
#     zone_ttl     => '600',
#     zone_refresh => '86400',
#     zone_retry   => '7200',
#     zone_expire  => '2592000',
#     zone_minimum => '600',
# }
#
# bind::zone { "intranet/test.com":
#     allow_update => "none",
#     allow_query  => "any",
# }
#
# bind::zone { "*/test.com":
#     zone_ns => [ "ns01.test.com.", "ns02.test.com." ],
# }
#
#
define bind::zone (
    $order = "50",
    $zone_type = "master",
    $allow_notify = [],
    $allow_query = [],
    $allow_transfer = [],
    $allow_update = [],
    $masters = [],
    $zone_statistics = "",
    $also_notify = [],
    $zone_ttl =  "1h",
    $zone_soa = "${::fqdn}.",
    $zone_soa_email = "root.${::fqdn}.",
    $zone_refresh = "6h",
    $zone_retry = "1h",
    $zone_expire = "5w",
    $zone_minimum = "5m",
    $zone_ns = [ "${::fqdn}." ]
) {

    $view = inline_template('<%= File.dirname(name) %>')
    $zone = inline_template('<%= File.basename(name) %>')
    $basename = inline_template('<%= name.gsub("*","_common_") %>')

    $file = $zone_type ? {
        "delegation-only" => "",
        "forward"         => "",
        "hint"            => "",
        "master"          => "/etc/named/zones/${basename}.zone",
        "slave"           => "/var/named/slaves/${basename}.zone",
        default           => fail("Zone type \"${zone_type}\" not valid. Should be one of delegation-only, forward, hint, master or slave."),
    }

    case $view {
        '.':     {
                    # there is no view asociated
                    concatfile::part { "/etc/named.conf.d/${order}_zone_${zone}":
                        content => template("bind/zone.erb"),
                    }
                 }
        '*':     {
                    # all the views
                    $view_files = inline_template('<%
                    begin
                        scope.lookupvar("bind_views").split(",").each do |v| -%>/etc/named/views.d/<%= v %>.d/<%= order %>_zone_<%= zone %>;<% end
                    rescue
                        %><%
                    end %>')
                    $view_files_array = split($view_files, ";")
                    concatfile::part { $view_files_array:
                        content => template("bind/zone.erb"),
                    }
                 }
        default: {
                    # there is a view asociated
                    concatfile::part { "/etc/named/views.d/${view}.d/${order}_zone_${zone}":
                        content => template("bind/zone.erb"),
                    }
                 }
    }

    if $zone_type == 'master' {
        # cannot use concatfile because we need to parse the %%SERIAL%%
        file {
            "${file}.d":
                ensure   => directory,
                checksum => mtime,
                recurse  => true,
                purge    => $::bind::purge,
                notify   => Exec["${file}.d"];
            "${file}":
                ensure   => present,
                checksum => md5,
                notify   => Exec["${file}.d"];
        }

        exec { "${file}.d":
            notify      => Service["named"],
            command     => "find ${file}.d -maxdepth 1 \\( -type f -or -type l \\) -print0 | sort -nz | xargs -0 cat | sed \"s/%%SERIAL%%/`date +%s`/g\" > ${file}",
            refreshonly => true;
        }

        concatfile::part { "${file}.d/00_header":
            content => template("bind/zone_file.erb"),
        }
    }
}
