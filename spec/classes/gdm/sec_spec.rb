require 'spec_helper'

describe 'xwindows::gdm::sec' do

  base_facts = {
    :gdm_version => '2'
  }
  let(:facts){base_facts}

  it { is_expected.to create_class('xwindows::gdm::sec') }

#  it { should contain_gconf('banner_message_enable') }
#  it { should contain_gconf('banner_message_text') }
#  it { should contain_gconf('disable_user_list') }

  @set_these = [
    'daemon_chooser', 'daemon_remote_greeter', 'daemon_standard_x_server', 'disable_chooser_button',
    'standard_server_priority', 'terminal_server_flex', 'terminal_server_handled'
  ]
  @set_these.each do |rule|
    it { is_expected.to contain_xwindows__gdm__set(rule) }
  end

end
