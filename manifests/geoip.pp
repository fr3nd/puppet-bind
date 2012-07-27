# == Class bind::geoip
#
# Include the GeoIP.acl file which contains a different ACL for each country,
# and inside this ACL it has all the IP's belonging to the country acording
# to the Maxmind GeoIP database
#
# See http://phix.me/geodns/ for more information about how to use this ACL in
# bind
#
# To generate the GeoIP.acl file, use the generate_geoip_views.sh script
# located into the "files" directory
#
class bind::geoip {

    file { "/etc/named/GeoIP.acl":
        ensure  => present,
        source  => "puppet:///modules/bind/GeoIP.acl",
        require => Package["bind-chroot"],
        notify  => Service["named"],
    }

    bind::include { "/etc/named/GeoIP.acl": }

}
