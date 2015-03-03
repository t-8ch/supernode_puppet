class postfix () {
  package { 'postfix': ensure => installed, }
  package { 'pwgen': ensure => installed, }

  service { 'postfix':
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => false,
    require => [ Package['postfix'], Package['pwgen'] ],
  }
  file { 'main-cf':
    ensure => file,
    path => '/etc/postfix/main.cf',
    content => template('postfix/main.cf.erb'),
#    notify => Service['tinc'],
  }
  #"[mail.bb.ffm.freifunk.net] user:pass; postmap file
  exec { 'postfix_config_6':
  command => '/bin/bash -c "echo \"[mail.bb.ffm.freifunk.net]  $(/bin/hostname -s):$(/usr/bin/pwgen 10 -1)\" > /etc/postfix/sasl_passwd; /usr/sbin/postmap /etc/postfix/sasl_passwd;"',
  path => "['/usr/bin','/bin', '/usr/sbin']",
      unless  => '/bin/grep mail.bb.ffm.freifunk.net /etc/postfix/sasl_passwd'
  }
  
  exec { 'postfix_config_7':
  command => 'sed -i "/root:/d" /etc/aliases; /bin/bash -lc "echo \"root: admin@ffm.freifunk.net\"  >> /etc/aliases; newaliases"',
  path => "['/usr/bin','/bin', '/usr/sbin']",
  }
notify {"MAKE SURE TO run doveadm pw -ssha enter the PASSWORD and put $(/bin/hostname -s) into /etc/dovecot/passwd on mail.bb.ffm.freifunk.net":}

}
