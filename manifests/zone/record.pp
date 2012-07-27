# == Definition bind::zone::record
#
# Create a new DNS record inside a zone. The varname variable defines the
# record. It should have the following format:
#
# "record,record_type,[view/]zone"
#
# Some examples:
# * "test1,A,test.com"
# * "test2,A,greatbritain/test.com"
# * "test3,CNAME,*/test.com"
# * "test4.test.com.,MX 10,test.com"
#
# Parameters:
# * *namevar*: Define the dns record. See before for examples.
# * *order*: The order or priority of this directive. Default: 50
# * *ttl*: Define the ttl for the dns record
# * *data*: Array with all the data asociated to this dns record
# * *add_ptr*: Automatically add the PTR records to the apropiate reverse
#   zone. The reverse zone should be created beforehand
#
# Examples:
#
# bind::zone::record { "test1,A,test.com":
#   data => "192.168.1.1",
# }
#
# bind::zone::record { "test2,A,greatbritain/test.com":
#   data => [ "192.168.1.1", "192.168.1.2"],
# }
#
# bind::zone::record { "test3,CNAME,*/test.com":
#   ttl  => "300",
#   data => "192.168.1.1",
# }
#
# bind::zone::record { "test4.test.com.,MX 10,test.com":
#   data => [ "mail01.test.com", "mail02.test.com" ], "mail02.test.com" ],
# }
#
define bind::zone::record (
    $order = "50",
    $ttl = "",
    $data = [ "" ],
    $add_ptr = false
) {

    $zone = inline_template('<%= File.basename(name.split(",")[2]) %>')
    $view = inline_template('<%= File.dirname(name.split(",")[2]) %>')
    $record_type = inline_template('<%= name.split(",")[1] %>')
    $dns_class = inline_template('<% if record_type.split(" ").length == 2 and record_type.split(" ")[0] != "MX" %><%= record_type.split(" ")[0] %><% else -%>IN<% end -%>')
    $record = inline_template('<%= name.split(",")[0] %>')

    $data_prefix_sufix = $record_type ? {
        "TXT"   => "\"",
        "SPF"   => "\"",
        default => "",
    }

    case $view {
        '.':     { $file_name = "/etc/named/zones/${zone}.zone.d/${order}_${record}_${dns_class}_${record_type}" }
        '*':     { $file_name = "/etc/named/zones/_common_/${zone}.zone.d/${order}_${record}_${dns_class}_${record_type}" }
        default: { $file_name = "/etc/named/zones/${view}/${zone}.zone.d/${order}_${record}_${dns_class}_${record_type}" }
    }

    concatfile::part { $file_name:
        content => template("bind/zone_record.erb"),
    }

    if $add_ptr {
        if $record_type == "A" or $record_type == "IN A" {

            $record_name = inline_template('<% data.each do |ip| -%>
<%
ip4 = ip.gsub(/([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/, \'\4\')
reverse_zone_name = ip.gsub(/([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/, \'\3.\2.\1.in-addr.arpa\')
if view != "."
    reverse_zone = view + "/" + reverse_zone_name
else
    reverse_zone = reverse_zone_name
end
-%>
<%= ip4 %>,PTR,<%= reverse_zone -%>;<% end -%>')
            $record_name_array = split($record_name, ";")

            bind::zone::record { $record_name_array:
                data => "${record}.${zone}.",
            }
        }
    }
}
