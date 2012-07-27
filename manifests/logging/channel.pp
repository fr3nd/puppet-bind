# == Definition: bind::logging::channel
#
# Configure a new logging channel.
#
# Parameters:
# * *order*: The order or priority of this directive. Default: 50
# * *channel_type*: What kind of channel to set up. Available options:
#   file | syslog | stderr | null
# * *syslog_facility*: When channel_type == syslog, the syslog facility where
#   to log to. Available options: kern | user | mail | daemon | auth | syslog
#   | lpr | news | uucp | cron | authpriv | ftp | local0 | local1 | local2 |
#   local3 | local4 | local5 | local6 | local7
# * *severity*: When channel_type == syslog, the severity level. Available
#   options: critical | error | warning | notice | info  | debug [ level ] |
#   dynamic
# * *file*: When channel_type == file, the file where to log to
# * *versions*: When channel_type == file, how many versions of the file will
#   be saved each time the file is opened
# * *size*: When channel_type == file, if set, then renaming is only done when
#   the file being opened exceeds the indicated size
# * *print_category*: If yes then the category of the message will be logged as
#   well
# * *print_severity*: If yes then the severity level of the message will be
#   logged
# * *print_time*: If yes then the date and time will be logged
#
define bind::logging::channel (
    $order = "50",
    $channel_type = "syslog",
    $syslog_facility = "daemon",
    $severity = "info",
    $file = "",
    $versions = "",
    $size = "",
    $print_category = "",
    $print_severity = "",
    $print_time = ""
) {

    concatfile::part { "/etc/named/logging.d/logging.d/${order}_channel_${name}":
        content => template("bind/logging_channel.erb")
    }

}
