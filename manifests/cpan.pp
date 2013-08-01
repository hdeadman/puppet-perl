# Define: perl::cpan
#
# This defined type can be used to install Perl modules via CPAN.
# It's also possible to force install a module, and setup an environment.
#
# Parameters:
#
# [*ensure*]
# Ensure value
#
# [*env*]
# Environment setting
#
# [*force*]
# Should the module be forcefully installed?
#
# [*timeout*]
# Timeout value.
##
# Usage:
#
# To install a module with no special requirements:
#   perl::cpan { 'DBI': }
#
# To install a module which requires a bit more coercion, e.g. DBD::Oracle:
#   perl::cpan { 'DBD::Oracle':
#     env    => ['ORACLE_HOME=/software/oracle/11.2.0.3'],
#     force  => true
#   }
##
# Requires:
#
define perl::cpan ($ensure = 'present', $env = undef, $force = false, $timeout = 120) {
  # Install or uninstall?
  if $ensure == 'present' {
    # Set command based on force or not...
    if $force == true {
      $cmd = "cpan -f -i ${name}"
    } else {
      $cmd = "cpan -i ${name}"
    }

    exec { "cpan_load_${name}":
      path        => ['/usr/bin/', '/bin'],
      environment => $env,
      command     => $cmd,
      unless      => "pmvers ${name}",
      timeout     => $timeout,
      require     => File['configure_shared_cpan'],
    }

  } elsif $ensure == 'absent' {
    if $name != "App::pmuninstall" {
      exec { "cpan_unload_${name}":
        path    => ['/usr/bin/', '/bin', '/usr/local/bin'],
        command => "pm-uninstall ${name}",
        onlyif  => "pmvers ${name}",
        timeout => $timeout,
        require => Exec['install_pmuninstall'],
      }
    } else {
      warning("App::pmuninstall is required, and will not be uninstalled on ${fqdn}")
    }

  }
}

# Term::ReadLine::Gnu is special, the module isn't to be included directly.Naughty.
# for it and similar CPAN modules try something like this in your manifest
# exec{"install_readline_gnu":
#   path    => ['/usr/bin/','/bin'],
#   command => "cpan -i Term::ReadLine::Gnu",
#   # unless  => "perl -MTerm::ReadLine::Gnu -e 'print \"Term::ReadLine::Gnu loaded\"'",
#   creates => '/usr/local/lib/perl/5.14.2/Term/ReadLine/Gnu.pm',
#   timeout => 600,
#   require => [Package[$perl::package],Exec['con
