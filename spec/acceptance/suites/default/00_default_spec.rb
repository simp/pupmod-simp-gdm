require 'spec_helper_acceptance'

test_name 'simp::gdm class'

describe 'simp::gdm class' do
  let(:manifest) {
    <<-EOS
      include 'gdm'

      runlevel { '5': persist => true }
    EOS
  }

  context 'on the hosts' do
    hosts.each do |host|
      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should require two runs' do
        # This needs two runs due to the GDM version fact
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent once stable' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      it 'should be running GDM' do
        on(host, 'pgrep -u gdm')
      end

      it 'should be running GDM after reboot' do
        host.reboot
        on(host, 'pgrep -u gdm')
      end
    end
  end
end
