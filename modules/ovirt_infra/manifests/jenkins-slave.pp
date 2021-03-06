class ovirt_infra::jenkins-slave {
  package {'java-1.7.0-openjdk-devel':
    ensure => installed,
  }

  user {'jenkins':
    ensure => present,
  }

  file {
    '/home/jenkins':
      ensure => directory,
      mode   => '0700',
      owner  => 'jenkins',
      group  => 'jenkins';
    '/home/jenkins/.ssh':
      ensure => directory,
      mode   => '0700',
      owner  => 'jenkins',
      group  => 'jenkins';
  }

  ssh_authorized_key {
    'jenkins@ip-10-114-123-188':
      key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAykXy+X1qUI/TyblF5J35A1bexPeFWj7SmzzcClS3GzQ8jEaV7AaOzbvyl2dQ8P4nh8tr2nSeT7LAFYWhIGscy6V7p5vMRr3mUzRA/E/g3r9wdmdDcPLOqfpJWiLTDlA3XQyFhJnwQopGRBSf5yzFGWFezH+rjzlwBDDN2mQkI/WuSEBh+UT/9+E7JvQBVhg2hapXszfSrrtrVniw/1TvNJEvR+wdwxCUkJWP+LZOtdbGIYQZMkmw8yMNy/fkEfxR3CLge65rDCbxqlDkqFff0VWcwd3SBXdIo4T1401kIjcPiPR9npib7Ra88QiWXIazHW05ejp+m2W136zmYmfxFw==',
      type    => 'ssh-rsa',
      user    => 'jenkins';
  }

  augeas { 'vdsm unit test':
    context => '/files/etc/sudoers',
    changes => [
      'set Cmnd_Alias[alias/name = "VDSMUT"]/alias/name VDSMUT',
      'set Cmnd_Alias[alias/name = "VDSMUT"]/alias/command[1] /bin/mount',
      'set Cmnd_Alias[alias/name = "VDSMUT"]/alias/command[2] /bin/umount',
      'set Cmnd_Alias[alias/name = "VDSMUT"]/alias/command[3] /usr/bin/ksflatten',
      'set Cmnd_Alias[alias/name = "VDSMUT"]/alias/command[4] /usr/bin/livecd-creator',
      'set Cmnd_Alias[alias/name = "VDSMUT"]/alias/command[5] /usr/bin/yum',
      'set Cmnd_Alias[alias/name = "VDSMUT"]/alias/command[6] /usr/sbin/setenforce',
    ],
  }

  augeas { 'jenkins VDSMUT':
    context => '/files/etc/sudoers',
    changes => [
      'set spec[user = "jenkins"]/user jenkins',
      'set spec[user = "jenkins"]/host_group/host ALL',
      'set spec[user = "jenkins"]/host_group/command VDSMUT',
      'set spec[user = "jenkins"]/host_group/command/runas_user root',
      'set spec[user = "jenkins"]/host_group/command/tag NOPASSWD',
    ],
  }

  augeas { 'jenkins !requiretty':
    context => '/files/etc/sudoers',
    changes => [
      'set Defaults[type=":jenkins"]/type :jenkins',
      'clear Defaults[type=":jenkins"]/requiretty/negate',
    ],
  }
}
