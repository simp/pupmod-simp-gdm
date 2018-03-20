require 'spec_helper'

describe 'gdm::sec' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts.merge({:gdm_version => '2'}) }

        it { is_expected.to create_class('gdm::sec') }

        @set_these = [
          'daemon_chooser', 'daemon_remote_greeter', 'daemon_standard_x_server', 'disable_chooser_button',
          'standard_server_priority', 'terminal_server_flex', 'terminal_server_handled'
        ]
        @set_these.each do |rule|
          it { is_expected.to contain_gdm__set(rule) }
        end
      end
    end
  end
end
