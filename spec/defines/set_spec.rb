require 'spec_helper'

describe 'gdm::set' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        let(:title) { 'daemon_chooser' }

        let(:params) { {:section => 'daemon', :key => 'Chooser', :value => false } }

        it {
          is_expected.to contain_ini_setting("GDM custom config #{title}").with({
            'ensure'  => 'present',
            'path'    => '/etc/gdm/custom.conf',
            'section' => params[:section],
            'setting' => params[:key],
            'value'   => params[:value],
            'require' => 'Class[Gdm::Install]',
            'notify'  => 'Class[Gdm::Service]'
          })
        }
      end
    end
  end
end
