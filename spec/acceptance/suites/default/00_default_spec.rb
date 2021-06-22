require 'spec_helper_acceptance'

test_name 'simp::gdm class'

describe 'simp::gdm class' do
  let(:manifest) {
    <<-EOS
      include 'gdm'

      runlevel { 'graphical': }
    EOS
  }

  hosts.each do |host|
    context "on #{host}" do
      it 'enables epel' do
        enable_epel_on(host)
      end

      # Work around the issue where the system hangs. I don't quite recall what
      # the issue was here but on some versions of EL7 there was a bug where
      # the system would not allow changing runlevels and would become
      # completely unresponsive.
      it 'should have the latest packages' do
        on(host, 'yum -y update')
      end

      it 'should require a reboot and relabel' do
        # This is needed to get the SELinux contexts worked out properly
        on(host, 'touch /.autorelabel')
        host.reboot
      end

      it 'should work but may have errors' do
        apply_manifest_on(host, manifest, :allow_all_exit_codes => true)
      end

      it 'should require another run' do
        # This needs two runs due to the GDM version fact
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent once stable' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      it 'should have GDM started' do
        result = on(host, "systemctl status gdm.service")
        expect(result.stdout).to match(/Active: active \(running\)/)
        retry_on(host, 'pgrep -u gdm -f /*greeter*/')
      end

      it 'should be running GDM after reboot' do
        host.reboot
        retry_on(host, 'pgrep -u gdm -f /*greeter*/')
        result = on(host, "systemctl status gdm.service")
        expect(result.stdout).to match(/Active: active \(running\)/)
      end
    end
  end
end
