class mcollective::rabbitmq(
  $stompuser     = "mcollective",
  $stomppassword = "mcollective",
  $stompport     = "61613",
  ){

  define access_to_stomp_port($port, $protocol='tcp') {
    $rule = "-p $protocol -m state --state NEW -m $protocol --dport $port -j ACCEPT"
    exec { "access_to_cobbler_${protocol}_port: $port":
      command => "iptables -t filter -I INPUT 1 $rule; \
      /etc/init.d/iptables save",
      unless => "iptables -t filter -S INPUT | grep -q \"^-A INPUT $rule\""
    }
  }


  case $::osfamily {
      'Debian': {
      }
      'RedHat': {
        access_to_stomp_port { "${stompport}_tcp": port => $stompport }
      }
      default: {
        fail("Unsupported osfamily: ${osfamily} for os ${operatingsystem}")
      }
    }

  class { 'rabbitmq::server':
    service_ensure     => 'running',
    delete_guest_user  => true,
    config_cluster     => false,
    cluster_disk_nodes => [],
    config_stomp       => true,
    stomp_port         => $stompport,
  }
        
  rabbitmq_user { $stompuser:
    admin     => true,
    password  => $stomppassword,
    provider  => 'rabbitmqctl',
    require   => Class['rabbitmq::server'],
  }
  
  rabbitmq_user_permissions { "${stompuser}@/":
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
    require              => Class['rabbitmq::server'],
  }


  # TODO
  # IMPLEMENT RABBITMQ PLUGIN TYPE IN rabbitmq MODULE

  if ! defined(Service['rabbitmq::server']){
    @service { 'rabbitmq::server' : }
  }

  exec {"rabbit-plugins":
    path => '/usr/sbin/:/usr/lib/rabbitmq/bin/',
    command => 'rabbitmq-plugins enable amqp_client rabbitmq_stomp',
    require   => Class['rabbitmq::server'],
    notify   => Service['rabbitmq-server']
  }
}
