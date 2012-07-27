# == Definition: bind::logging::category
#
# Configure a new logging category.
#
# Parameters:
# * *name*: Name of the logging category
# * *order*: The order or priority of this directive. Default: 50
# * *channel_names*: Array with all the chanel names to be included into the
#   category
#
define bind::logging::category (
    $order = "50",
    $channel_names = []
) {

    concatfile::part { "/etc/named/logging.d/logging.d/${order}_category_${name}":
        content => template("bind/logging_category.erb")
    }

}
