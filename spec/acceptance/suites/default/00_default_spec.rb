require 'spec_helper_acceptance'

test_name 'simp::gdm class'

describe 'simp::gdm class' do
  let(:manifest) do
    <<-EOS
      include 'gdm'

      runlevel { 'graphical': }
    EOS
  end

  hosts.each do |host|
    context "on #{host}" do
      it 'enables epel' do
        enable_epel_on(host)
      end

      # Work around the issue where the system hangs. I don't quite recall what
      # the issue was here but on some versions of EL7 there was a bug where
      # the system would not allow changing runlevels and would become
      # completely unresponsive.
      it 'has the latest packages' do
        on(host, 'yum -y update')
      end

      it 'requires a reboot and relabel' do
        # This is needed to get the SELinux contexts worked out properly
        on(host, 'touch /.autorelabel')
        host.reboot
      end

      it 'works but may have errors' do
        apply_manifest_on(host, manifest, allow_all_exit_codes: true)
      end

      it 'requires another run' do
        # This needs two runs due to the GDM version fact
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent once stable' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      it 'has GDM started' do
        result = on(host, 'systemctl status gdm.service')
        expect(result.stdout).to match(%r{Active: active \(running\)})
        retry_on(host, 'pgrep -u gdm -f /*greeter*/')
      end

      it 'is running GDM after reboot' do
        host.reboot
        retry_on(host, 'pgrep -u gdm -f /*greeter*/')
        result = on(host, 'systemctl status gdm.service')
        expect(result.stdout).to match(%r{Active: active \(running\)})
      end
    end
  end
end
