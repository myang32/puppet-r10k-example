# Creates client config files on OpenVPN server
# Takes a hash of client configs and uses the resource name as key
define profiles::vpn::client_config (
    $ips
) {
    file { "/etc/openvpn/client-configs/${name}":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0666',
        content => template('profiles/vpn/client-config.erb'),
        require => [
            Package['openvpn'],
            File['/etc/openvpn/client-configs']
        ],
        notify  => Service['openvpn']
    }
}
