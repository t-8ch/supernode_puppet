class supernode {
  if $::supernodenum > 8 {
    fail('Supernodenum not in range 1-8')
  }
  if $::supernodenum < 1 {
    fail('Supernodenum not in range 1-8')
  }
  $ipv4_subnets = {
                1 => [0, 7], 2 => [56, 63], 3 => [8, 15], 4 => [16, 23],
                5 => [24, 31], 6 => [32, 39], 7 => [40, 47], 8 => [48, 55]
  }
  $ipv6_subnets = {
                1 => 'b101', 2 => 'b102', 3 => 'b103', 4 => 'b104',
                5 => 'b105', 6 => 'b106', 7 => 'b107', 8 => 'b108'
  }
  $backbone_ip_suffixes = {
                1 => 21, 2 => 22, 3 => 23, 4 => 24,
                5 => 25, 6 => 26, 7 => 27, 8 => 28
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
  $backbone_ip_suffix = $backbone_ip_suffixes[ $::supernodenum ]

  include apache2
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
  class { 'fastd':
    supernodenum            => $::supernodenum,
    fastd_key               => $::fastd_key,
    fastd_web_service_auth  => $::fastd_web_service_auth,
  }
  class { 'fastd_web_service':
    fastd_web_service_auth  => $::fastd_web_service_auth,
  }
  include iptables
  class { 'nrpe':
    backbone_ip_suffix  => $backbone_ip_suffix,
  }
  include puppet
  class { 'radvd':
    supernodenum  => $::supernodenum,
  }
  include routing
  include rsyslog
  include sources_apt
  include sysctl_conf
  class { 'tinc':
    backbone_ip_suffix  => $backbone_ip_suffix,
    ipv4_subnet_start   => $ipv4_subnet_start,
    supernodenum        => $::supernodenum,
  }
  include unbound

  service { 'ssh':
    ensure => running,
  }

  package { 'vim':
    ensure  => installed,
  }
}
