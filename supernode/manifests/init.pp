class supernode {
  if $::supernodenum > 20 {
    fail('Supernodenum not in range 1-20')
  }
  if $::supernodenum < 1 {
    fail('Supernodenum not in range 1-20')
  }
  file { '/etc/fw':
    ensure => directory,
    mode => 0755,
  }

exec {'check_presence':
  command => '/bin/false',
  provider => shell,
  unless => '/usr/bin/test -f /etc/fw/$(hostname -f).fw',
}

package {'xinetd':
  ensure => installed,
}
package {'monitoring-plugins':
  ensure => installed,
}
package {'check-mk-agent':
  ensure => installed,
}

package { 'nagios-nrpe-server':
  ensure => installed,
}
package { 'fail2ban':
	ensure => installed,
}
  service { 'fail2ban':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => true,
    require     => [Package['fail2ban'],Exec['firewall']],
  }

  file { 'check_vpn':
    ensure => file,
    path => '/root/check_vpn',
    content => template('supernode/check_vpn.erb'),
    mode => 0755,
  }
  file { 'check_vpn-cron':
    ensure => file,
    path => '/etc/cron.d/check_vpn',
    content => template('supernode/check_vpn-cron.erb'),
    mode => 0755,
  }
  file { '/root/testmessage':
    ensure => file,
    path => '/root/testmessage',
    content => template('supernode/testmessage.erb'),
    mode => 0644,
  }
			#
  $ipv4_net	   = '10.126'
  $ipv6_net_prefix =  '2001:1A50:11:4:'
  $ipv6_rnet_prefix =  'fddd:5d16:b5dd:'
  $ipv6_rnet_mask = 48

  $ipv4_subnets = {
                1 => [0, 7], 2 => [8, 15], 3 => [16, 23], 4 => [24, 31], 5 => [32, 39], 
                6 => [40, 47], 7 => [48, 55], 8 => [56, 63], 9 => [64, 71], 10 => [72, 79],
                11 => [80, 87], 12 => [88, 95], 13 => [96, 103], 14 => [104, 111], 15 => [112, 129],
                16 => [130, 137], 17 => [138, 145], 18 => [146, 153], 19 => [154, 161], 20 => [162, 169]
  }
  $ipv6_subnets = {
                1 => 'b101', 2 => 'b102', 3 => 'b103', 4 => 'b104', 5 => 'b105', 
                6 => 'b106', 7 => 'b107', 8 => 'b108', 9 => 'b109', 10 => 'b110',
                11 => 'b111', 12 => 'b112', 13 => 'b113', 14 => 'b114', 15 => 'b115', 
                16 => 'b116', 17 => 'b117', 18 => 'b118', 19 => 'b119', 20 => 'b120'
  }
  $backbone_ip_suffixes = {
                1 => 21, 2 => 22, 3 => 23, 4 => 24, 5 => 25, 6 => 26, 7 => 27, 8 => 28, 9 => 29, 10 => 30,
                11 => 31, 12 => 32, 13 => 33, 14 => 34, 15 => 35, 16 => 36, 17 => 37, 18 => 38, 19 => 39, 20 => 40,
  }            

  $ipv4_subnet_start  = $ipv4_subnets[ $::supernodenum ][0]
  $ipv4_subnet_end    = $ipv4_subnets[ $::supernodenum ][1]
  if $::supernodenum  == 1 {
    $ipv4_suffix  = 3
  }
  else {
    $ipv4_suffix  = 1
  }
  $ipv6_subnet        = $ipv6_subnets[ $::supernodenum ]
  $ipv6_net = "${ipv6_net_prefix}${ipv6_subnet}"
  $ipv6_rnet = "${ipv6_rnet_prefix}${ipv6_subnet}"
  $backbone_ip_suffix = $backbone_ip_suffixes[ $::supernodenum ]

#  include apache2
  include apt
  class { 'batman':
    ipv4_suffix       => $ipv4_suffix,
    ipv4_subnet_start => $ipv4_subnet_start,
    ipv6_subnet       => $ipv6_subnet,
  }
  class { 'dhcpd':
    supernodenum      => $::supernodenum,
    ipv4_subnet_start => $ipv4_subnet_start,
    ipv4_subnet_end   => $ipv4_subnet_end,
  }
  class { 'fastd-1280':
#    eigene_ipv4ip_start            => $ipv4_subnet_start,
#    ipv4_suffix                    => $ipv4_suffix,
    supernodenum            => $::supernodenum,
    fastd_key               => $::fastd_key,
    ipv6_net                => "$ipv6_net",
    ipv6_rnet                => "$ipv6_rnet",
    ipv6_rnet_prefix	=> "$ipv6_rnet_prefix",
    ipv6_rnet_mask 	=> "$ipv6_rnet_mask",
  }
  class { 'fastd':
#    eigene_ipv4ip_start            => $ipv4_subnet_start,
#    ipv4_suffix                    => $ipv4_suffix,
    supernodenum            => $::supernodenum,
    fastd_key               => $::fastd_key,
    ipv6_net                => "$ipv6_net",
    ipv6_rnet                => "$ipv6_rnet",
    ipv6_rnet_prefix	=> "$ipv6_rnet_prefix",
    ipv6_rnet_mask 	=> "$ipv6_rnet_mask",
  }
#  class { 'fastd_web_service':
#    fastd_web_service_auth  => $::fastd_web_service_auth,
#  }
  include ff-tools
  include puppet
  class { 'radvd':
    ipv6_subnet  => $ipv6_subnet,
    ipv6_net => $ipv6_net,
    ipv6_rnet => $ipv6_rnet,
  }
  include routing
  include rsyslog
  include sources_apt
  include sysctl_conf
  include openvpn
  class { 'collectd':
    supernodenum => $::supernodenum,
  }

#  class { 'tinc':
#    backbone_ip_suffix  => $backbone_ip_suffix,
#    ipv4_subnet_start   => $ipv4_subnet_start,
#    ipv6_subnet         => $ipv6_subnet,
#  }
#  include unbound
  include postfix 
  include sshd

  package { 'ntp':
    ensure  => installed,
  }
  package { 'vim':
    ensure  => installed,
  }
  exec { 'firewall':
    command => '/bin/sed -i "s|exit|/etc/fw/*.fw;exit|" /etc/rc.local',
    path => "['/usr/bin','/bin', '/usr/sbin']",
    unless  => '/bin/grep /etc/fw/ /etc/rc.local',
    require => Exec["check_presence"],
  }

}
