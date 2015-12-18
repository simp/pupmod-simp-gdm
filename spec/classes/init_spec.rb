require 'spec_helper'

describe 'xwindows' do

  let(:facts) { {:runlevel => '5'} }

  it { is_expected.to create_class('xwindows') }

  it do
    is_expected.to contain_file('/etc/skel/.xserverrc').with({
      'content' => 'exec /usr/bin/Xorg -audit 4 -s 15 -auth $HOME/.Xauthorization &'
    })
  end

  @package = [
    'xorg-x11-apps','xorg-x11-drivers', 'xorg-x11-xinit', 'xorg-x11-twm', 'xterm',
    'xorg-x11-fonts-100dpi', 'xorg-x11-fonts-75dpi', 'xorg-x11-fonts-ISO8859-1-100dpi',
    'xorg-x11-fonts-ISO8859-1-75dpi', 'xorg-x11-fonts-Type1', 'xorg-x11-fonts-misc',
    'xorg-x11-server-Xorg', 'dejavu-lgc-sans-fonts', 'dejavu-lgc-sans-mono-fonts',
    'dejavu-lgc-serif-fonts', 'dejavu-sans-fonts', 'dejavu-sans-mono-fonts',
    'dejavu-serif-fonts', 'bitmap-console-fonts', 'bitmap-fangsongti-fonts',
    'bitmap-fixed-fonts', 'bitmap-fonts-compat', 'bitmap-lucida-typewriter-fonts',
    'bitmap-miscfixed-fonts', 'liberation-mono-fonts', 'liberation-sans-fonts',
    'liberation-serif-fonts'
  ]
  @package.each do |pkg|
    it { is_expected.to contain_package(pkg) }
  end

  context 'with runlevel = 5' do
    let(:facts) { {:runlevel => '4'} }

    it { is_expected.to contain_exec('/sbin/telinit 5') }
  end

end
