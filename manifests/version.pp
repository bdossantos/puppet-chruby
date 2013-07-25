# Installs a ruby version via rbenv.
# Takes ensure, env, and version params.
#
# Usage:
#
#     ruby::version { '1.9.3-p194': }

define ruby::version(
  $ensure  = 'installed',
  $env     = {},
  $version = $name
) {
  require ruby

  case $::operatingsystem {
    'Darwin': {
      require xquartz

      $os_env = {
        'CFLAGS' => '-I/opt/X11/include'
      }
    }

    default: {
      $os_env = {}
    }
  }

  $dest = "${ruby::chruby_rubies}/${version}"

  if $ensure == 'absent' {
    file { $dest:
      ensure => absent,
      force  => true
    }
  } else {
    $default_env = {
      'CC'         => '/usr/bin/cc',
    }

    $final_env = merge(merge($default_env, $os_env), $env)

    exec { "ruby-build-${version}":
      command     => "${ruby::chruby_root}/ruby-build/bin/ruby-build ${version} ${dest}",
      cwd         => $ruby::chruby_rubies,
      provider    => 'shell',
      timeout     => 0,
      creates     => $dest,
      user        => $ruby::user,
    }
    ->
    ruby::gem { "bundler for ${version}":
      gem     => 'bundler',
      ruby    => $version,
      version => '~> 1.0'
    }

    Exec["ruby-build-${version}"] {
      environment +> sort(join_keys_to_values($final_env, '='))
    }
  }
}
