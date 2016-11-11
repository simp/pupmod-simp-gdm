# == Class: xwindows::gdm::sec
#
# Some default tweaks for securing GDM.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class xwindows::gdm::sec {
  if ( versioncmp($::gdm_version, '3') < 0 ) and ( versioncmp($::gdm_version, '0.0.0') > 0 ) {
    # Disable the Chooser
    xwindows::gdm::set { 'daemon_chooser':
      section => 'daemon',
      key     => 'Chooser',
      value   => false
    }

    # Set the remote greeter
    xwindows::gdm::set { 'daemon_remote_greeter':
      section => 'daemon',
      key     => 'RemoteGreeter',
      value   => '/usr/libexec/gdmgreeter'
    }

    # Set the standard X server
    xwindows::gdm::set { 'daemon_standard_x_server':
      section => 'daemon',
      key     => 'StandardXServer',
      value   => '/usr/bin/Xorg -br -audit 4 -s 15'
    }

    # Disable the chooser button
    xwindows::gdm::set { 'disable_chooser_button':
      section => 'greeter',
      key     => 'ChooserButton',
      value   => false
    }

    # Set the standard sever priority
    xwindows::gdm::set { 'standard_server_priority':
      section => 'server-Standard',
      key     => 'priority',
      value   => '0'
    }

    # Set the terminal server options
    xwindows::gdm::set { 'terminal_server_flex':
      section => 'server-Terminal',
      key     => 'flexible',
      value   => true
    }

    xwindows::gdm::set { 'terminal_server_handled':
      section => 'server-Terminal',
      key     => 'handled',
      value   => true
    }
  }
}
