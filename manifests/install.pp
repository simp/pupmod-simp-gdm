# Install the GDM components
#
# @api private
class gdm::install {

  assert_private()

  simplib::assert_metadata($module_name)

  $_package_defaults = { 'ensure' => $gdm::package_ensure }

  simplib::install { 'gdm packages':
    packages => $gdm::packages,
    defaults => $_package_defaults
  }
}
