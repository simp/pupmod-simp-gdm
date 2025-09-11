require 'spec_helper_acceptance'

test_name 'simp::gdm class STIG'

describe 'simp::gdm class STIG' do
  let(:manifest) do
    <<~EOS
      include 'gdm'

      runlevel { 'graphical': }
    EOS
  end

  let(:hieradata) do
    <<~EOM
      ---
      compliance_markup::enforcement:
        - disa_stig
    EOM
  end

  hosts.each do |host|
    context "on #{host}" do
      let(:hiera_yaml) do
        <<~EOM
          ---
          version: 5
          hierarchy:
            - name: Common
              path: common.yaml
            - name: Compliance
              lookup_key: compliance_markup::enforcement
          defaults:
            data_hash: yaml_data
            datadir: "#{hiera_datadir(host)}"
        EOM
      end

      it 'works with no errors' do
        create_remote_file(host, host.puppet['hiera_config'], hiera_yaml)
        write_hieradata_to(host, hieradata)

        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end
    end
  end
end
