Bind puppet module
==================

A Puppet module to fully manage bind.

There are many bind puppet modules arround but none of those is able to manage a full configuration like creating new zones or dns records. Using this module you will never need to manually edit a zone file again.

As a plus, it can also manage the GeoIP configuration as defined in http://phix.me/geodns/

Usage
-----

This module is quite complex to use as tries to abstract a full bind configuration inside puppep. However, it's fully documented using puppetdoc.

A simple configuration with one test zone:

<pre>
include bind

class { "bind::options":
    listen_on => "any",
}

include bind::logging

bind::logging::channel { "default_debug":
    channel_type => "file",
    file         => "data/named.run",
    severity     => "dynamic",
}

include bind::geoip

bind::acl { "dns_servers":
    sources => [
                "192.168.1.10",
                "192.168.1.11",
               ]
}

bind::zone { "test.com":
    allow_update => "dns_servers",
    allow_query  => "any",
}

bind::zone::record {
    "www,A,test.com":
        data => "192.168.1.20";
    "mail,A,test.com":
        data => "192.168.1.21";
    "test.com.,MX 10,test.com":
        data => "mail.test.com.";
}

</pre>

Requirements
------------

* puppet-concat module https://github.com/ripienaar/puppet-concat

Authors
-------

* **Carles Amigo** <fr3nd at fr3nd dot net>

