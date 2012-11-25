class octopress (
  # If you don't want Puppet to manage Ruby with RBEnv, set this to false
  # Set a ruby version with $ruby_version
  # RBEnv will setup under the user home specfied as $octopress_user & $octopress_home
  $manage_ruby  = true,
  $ruby_version = '1.9.3-p327',
  $user         = 'octopress',
  $home         = '/home/octopress',
  #
  $install_dir  = '/opt/octopress',
  $source_code  = 'git://github.com/imathis/octopress.git',
) {

  if $manage_ruby {

    user { $octopress::user:
      ensure => present,
      gid    => $octopress::user,
      home   => $octopress::home,
    }

    group { $octopress::user:
      ensure => present,
    }

    file { $octopress::home:
      ensure => directory,
      owner  => $octopress::user,
    }

    rbenv::install { $octopress::user:
      group => $octopress::user,
      home  => $octopress::home,
    }

    rbenv::compile { $octopress::ruby_version:
      user => $octopress::user,
      home => $octopress::home,
    }

    exec { 'bundle install':
      environment => "RBENV_VERSION=${octopress::ruby_version}",
      cwd         => $octopress::install_dir,
      path        => "${octopress::home}/.rbenv/shims:${octopress::home}/.rbenv/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin",
      command     => 'bundle install',
      unless      => 'bundle check',
    }

  }

  vcsrepo { $octopress::install_dir:
      ensure   => present,
      provider => 'git',
      source   => $octopress::source_code,
  }

  file { $octopress::install_dir:
    ensure => present, 
    owner   => $octopress::user,
    group   => $octopress::user,
    mode    => '0755',
    require => Vcsrepo[$octopress::install_dir]
  }



}
