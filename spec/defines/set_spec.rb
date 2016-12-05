require 'spec_helper'

describe 'gdm::set' do

  let(:title) { 'daemon_chooser' }

  let(:params) { {:section => 'daemon', :key => 'Chooser', :value => false } }

  it do
    is_expected.to contain_augeas('gdm_set_daemon_chooser').with({
      'incl'    => '/etc/gdm/custom.conf',
      'lens'    => 'Gdm.lns',
      'changes' => ["set daemon/Chooser 'false'"],
      'require' => 'Package[gdm]'
    })
  end
end
