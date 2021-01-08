require 'spec_helper_acceptance'

test_name 'simp::gdm with gnome and pam and hidepid'

describe 'simp::gdm with gnome and pam and hidepid' do
let(:manifest) {
  <<-EOS
    include 'pam'

    pam::access::rule {'Vagrant User':
      users => [ 'vagrant' ],
      origins => ['LOCAL']
    }

    include 'simp::mountpoints::proc'
    include 'gdm'
  EOS
}
let(:hieradata){ <<-EOS
simp_options::pam: true
EOS
}

  hosts.each do |host|
    context "on #{host}" do
      it 'should set_up pam through hiera' do
         set_hieradata_on(host, hieradata)
      end

      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      # check that hide pid was set on the /proc file system
      it 'should have hidepid on /proc' do
        on(host, 'grep \'proc /proc\' /proc/mounts| grep hidepid=2')
      end

      # After this, you can try the GUI and see what happens
      it 'should have GDM started' do
        result = on(host, "systemctl status gdm.service")
        expect(result.stdout).to match(/Active: active \(running\)/)
      end

      # The gdm service may be up and running but it had errors
      # bring up the greeter so user can log in.  This just checks
      # if the greeter process is running.  It is started slightly differently in
      # el7 (dbus) and el8 (gdm-x-session) so just check for greeter.
      it 'should be running the greeter' do
        on(host,'pgrep -u gdm -f /*greeter*/')
      end

      # Restart GDM service and make sure everything comes back up
      it 'should restart gdm' do
        on(host, "systemctl restart gdm.service")
        sleep 5
        result = on(host, "systemctl status gdm.service")
        expect(result.stdout).to match(/Active: active \(running\)/)
        on(host,'pgrep -u gdm -f /*greeter*/')
      end

    end
  end

end
