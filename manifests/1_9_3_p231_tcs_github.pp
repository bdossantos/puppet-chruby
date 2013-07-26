# Installs ruby 1.9.3-p231-tcs-github blessed version from ruby-build.
#
# Usage:
#
#     include ruby::1_9_3_p231_tcs_github

class ruby::1_9_3_p231_tcs_github {
  require ruby
  require ruby::1_9_3_p231_tcs_github_1_0_32

  file { "${ruby::chruby_rubies}/1.9.3-p231-tcs-github":
    ensure  => symlink,
    force   => true,
    target  => "${ruby::chruby_rubies}/1.9.3-p231-tcs-github-1.0.32"
  }
}
