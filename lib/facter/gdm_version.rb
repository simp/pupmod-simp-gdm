# _Description_
#
# Set a fact to return the version of GDM that is installed.
# This is useful for applying the correct configuration file syntax.
#
Facter.add("gdm_version") do
        setcode do
            if ( File.exists?("/usr/sbin/gdm") && File.executable?("/usr/sbin/gdm") ) then
                %x{/usr/sbin/gdm --version}.chomp.split(/\s+/)[1]
            else
                "0.0.0"
            end
        end
end
