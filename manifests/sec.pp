# Some default tweaks for securing GDM.
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class gdm::sec {
  if ( versioncmp($::gdm_version, '3') < 0 ) and ( versioncmp($::gdm_version, '0.0.0') > 0 ) {
    # Disable the Chooser
    gdm::set { 'daemon_chooser':
      section => 'daemon',
      key     => 'Chooser',
      value   => false
    }

    # Set the remote greeter
    gdm::set { 'daemon_remote_greeter':
      section => 'daemon',
      key     => 'RemoteGreeter',
      value   => '/usr/libexec/gdmgreeter'
    }

    # Set the standard X server
    gdm::set { 'daemon_standard_x_server':
      section => 'daemon',
      key     => 'StandardXServer',
      value   => '/usr/bin/Xorg -br -audit 4 -s 15'
    }

    # Disable the chooser button
    gdm::set { 'disable_chooser_button':
      section => 'greeter',
      key     => 'ChooserButton',
      value   => false
    }

    # Set the standard sever priority
    gdm::set { 'standard_server_priority':
      section => 'server-Standard',
      key     => 'priority',
      value   => '0'
    }

    # Set the terminal server options
    gdm::set { 'terminal_server_flex':
      section => 'server-Terminal',
      key     => 'flexible',
      value   => true
    }

    gdm::set { 'terminal_server_handled':
      section => 'server-Terminal',
      key     => 'handled',
      value   => true
    }
  }
}
