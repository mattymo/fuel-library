$fuel_settings = parseyaml($astute_settings_yaml)

# this replaces removed postgresql version fact
$postgres_default_version = '8.4'

node default {

  Exec  {path => '/usr/bin:/bin:/usr/sbin:/sbin'}

  $centos_repos =
  [
   {
   "id" => "nailgun",
   "name" => "Nailgun",
   "url"  => "\$tree"
   },
   ]

  $cobbler_user = "cobbler"
  $cobbler_password = "cobbler"

  $puppet_master_hostname = "${hostname}.${domain}"

  $mco_pskey = "unset"
  $mco_vhost = "mcollective"
  $mco_user = "mcollective"
  $mco_password = "marionette"
  $mco_connector = "rabbitmq"

  $rabbitmq_naily_user = "naily"
  $rabbitmq_naily_password = "naily"

  $repo_root = "/var/www/nailgun"
  $pip_repo = "/var/www/nailgun/eggs"
  $gem_source = "http://${::fuel_settings['ADMIN_NETWORK']['ipaddress']}:8080/gems/"

  class { 'postgresql::server':
    config_hash => {
      'ip_mask_allow_all_users' => '0.0.0.0/0',
      'listen_addresses'        => '127.0.0.1',
    },
  }

  $ntp_servers = [$::fuel_settings['NTP1'], $::fuel_settings['NTP2'], $::fuel_settings['NTP3']]

  class { "openstack::clocksync":
    ntp_servers     => $ntp_servers,
    config_template => "ntp/ntp.conf.centosserver.erb",
  }

  class { "nailgun":
    package => "Nailgun",
    version => "0.1.0",
    naily_version => "0.1.0",
    nailgun_group => "nailgun",
    nailgun_user => "nailgun",
    venv => "/opt/nailgun",

    pip_index => "--no-index",
    pip_find_links => "-f file://${pip_repo}",
    gem_source => $gem_source,

    # it will be path to database file while using sqlite
    # (this is not implemented now)
    database_name => "nailgun",
    database_engine => "postgresql",
    database_host => "localhost",
    database_port => "5432",
    database_user => "nailgun",
    database_passwd => "nailgun",

    staticdir => "/opt/nailgun/share/nailgun/static",
    templatedir => "/opt/nailgun/share/nailgun/static",

    cobbler_url => "http://localhost/cobbler_api",
    cobbler_user => $cobbler_user,
    cobbler_password => $cobbler_password,

    mco_pskey => $mco_pskey,
    mco_vhost => $mco_vhost,
    mco_host => $::fuel_settings['ADMIN_NETWORK']['ipaddress'],
    mco_user => $mco_user,
    mco_password => $mco_password,
    mco_connector => "rabbitmq",

    rabbitmq_naily_user => $rabbitmq_naily_user,
    rabbitmq_naily_password => $rabbitmq_naily_password,
    puppet_master_hostname => $puppet_master_hostname,
    puppet_master_ip => $::fuel_settings['ADMIN_NETWORK']['ipaddress'],
  }

  Class['postgresql::server'] -> Class['nailgun']

}

