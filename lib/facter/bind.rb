ENV["PATH"]=":/bin:/sbin:/usr/bin:/usr/sbin"

bindexists = system "which named > /dev/null 2>&1"

if $?.exitstatus == 0
    Facter.add("bind_exists") do
        setcode do
            "true"
        end
    end
    Facter.add("bind_views") do
        setcode do
            %x{ls -1 /etc/named/views.d/*.view 2> /dev/null| xargs -L 1 basename 2> /dev/null | sed "s/\.view$//g" | xargs echo -n}.split(" ").join(",")
        end
    end
end
