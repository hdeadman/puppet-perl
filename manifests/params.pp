class perl::params {
  $perl_version   = 'UNSET'
  $package_ensure = 'present'
  

  # Calculate the package names, based on OS Family
  case $::osfamily {
    'Redhat' : {
      $perl_package    = 'perl'
      $cpan_package    = 'perl-CPAN'
      $pmtools_package = 'pmtools'
      $cpan_mirror     = 'ftp://mirror.bytemark.co.uk/CPAN/'
      $yaml_package    = 'perl-YAML'
    }
    'Debian' : {
      $perl_package    = 'perl'
      $cpan_package    = 'perl-CPAN'
      $pmtools_package = 'pmtools'
      $cpan_mirror     = 'ftp://mirror.bytemark.co.uk/CPAN/'
      $yaml_package    = 'libyaml-perl'
    }
    default  : {
      fail("The ${module_name} module is not currently supported on an ${::osfamily} based system.")
    }
  }

}
