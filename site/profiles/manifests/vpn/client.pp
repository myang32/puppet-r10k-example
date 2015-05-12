# OpenVPN client setup
# Keys should be copied to server before puppet runs
# Requires that dnsmasq be installed and running
class profiles::vpn::client {
    $openvpn_config = hiera('openvpn')
    $remote = $openvpn_config['remote']
    package { 'openvpn':
        ensure  => present,
        require => [
            Service['dnsmasq'],
        ],
    } ->
    file { '/etc/openvpn/keys':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0400',
    } ->
    file { "/etc/openvpn/${::fqdn}.conf":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        content => template('profiles/vpn/client.conf.erb'),
    } ~>
    service { 'openvpn':
        ensure    => running,
        name      => "openvpn@${::fqdn}",
        hasstatus => true,
        enable    => true,
        subscribe => [
            Service['dnsmasq'],
        ],
    }

    # Firewall rules
    firewall { '201 vpn rules':
        chain    => 'OUTPUT',
        state    => ['NEW'],
        outiface => 'eth0',
        action   => 'accept',
        proto    => 'all',
    }

    firewall { '202 vpn rules':
        chain  => 'INPUT',
        state  => ['ESTABLISHED', 'RELATED'],
        action => 'accept',
        proto  => 'all',
    }

    firewall { '203 vpn rules':
        chain    => 'FORWARD',
        state    => ['NEW'],
        outiface => 'eth0',
        action   => 'accept',
        proto    => 'all',
    }

    firewall { '204 vpn rules':
        chain  => 'FORWARD',
        state  => ['ESTABLISHED', 'RELATED'],
        action => 'accept',
        proto  => 'all',
    }

    firewall { '205 vpn rules':
        table    => 'nat',
        chain    => 'POSTROUTING',
        outiface => 'eth0',
        source   => '10.8.0.0/24',
        jump     => 'MASQUERADE',
        proto    => 'all',
    }
}
