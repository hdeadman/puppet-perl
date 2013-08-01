# Class: perl
#
# This class installs Perl, CPAN and PMTools on your system.
#
# Parameters:
#
# [*perl_version*]
# The Version of Perl to be installed
#
# [*ensure*]
# Ensure value
#
# [*cpan_mirror*]
# The CPAN mirror URL
#
# [*perl_package*]
# The name of the Perl package
#
# [*cpan_package*]
# The name of the CPAN package
#
# [*pmtools_package*]
# The name of the PMTools package
##
# Usage:
#
# To use the default configuration values, use:
#   include ::perl
#
# To specifiy configuration values, use:
#   class { '::perl':
#     perl_version    => '5.10',
#     cpan_mirror     => 'ftp://cpan-mirror.com',
#     perl_package    => 'perl',
#     cpan_package    => 'perl-CPAN',
#     pmtools_package => 'pmtools'
#   }
##
# Requires:
#
class perl (
  $perl_version    = $perl::params::perl_version,
  $ensure          = $perl::params::package_ensure,
  $cpan_mirror     = $perl::params::cpan_mirror,
  $perl_package    = $perl::params::perl_package,
  $cpan_package    = $perl::params::cpan_package,
  $pmtools_package = $perl::params::pmtools_package) inherits perl::params {
  # Install Perl
  if $perl_version == 'UNSET' {
    # Install all 3 required packages
    package { [$perl_package, $cpan_package, $pmtools_package]:
      ensure => $ensure
    }
  } else {
    # Install a specific perl version
    package { $perl_package:
      ensure => $perl_version
    }

    # Make sure that CPAN and PMTools are also installed.
    package { [$cpan_package, $pmtools_package]:
      ensure  => $ensure,
      require => Package[$perl_package]
    }
  }

  # Configure as required
  if $ensure == 'present' {
    file { 'configure_shared_cpan':
      path    => '/usr/share/perl5/CPAN/Config.pm',
      content => template("perl/MyConfig.pm.erb"),
      require => [Package[$perl::perl_package], Package[$perl::cpan_package]]
    }

    exec { "install_pmuninstall":
      path    => ['/usr/bin/', '/bin'],
      command => "cpan -i App::pmuninstall",
      unless  => "perl -MApp::pmuninstall -e 'print \"App::pmuninstall loaded\"'",
      timeout => 600,
      require => [Package[$perl::perl_package], Package[$perl::cpan_package], File['configure_shared_cpan']],
    }

  }

}
