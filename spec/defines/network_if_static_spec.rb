#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::if::static', :type => 'define' do

  context 'incorrect value: ipaddress' do
    let(:title) { 'eth77' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => 'notAnIP',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth77')}.to raise_error(Puppet::Error, /expects a match for Stdlib::IP::Address::V4::Nosubnet/)
    end
  end

  context 'incorrect value: ipv6address' do
    let(:title) { 'eth77' }
    let :params do {
      :ensure      => 'up',
      :ipaddress   => '1.2.3.4',
      :netmask     => '255.255.255.0',
      :ipv6address => 'notAnIP',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth77')}.to raise_error(Puppet::Error, /(expects a value of type Undef, Stdlib::IP::Address::V6|expects a match for Variant\[Stdlib::IP::Address::V6::Full .*, Stdlib::IP::Address::V6::Compressed)/)
    end
  end

  context 'incorrect hash value: ipv6address' do
    let(:title) { 'eth77' }
    let :params do {
      :ensure      => 'up',
      :ipaddress   => '1.2.3.4',
      :netmask     => '255.255.255.0',
      :ipv6address => { 'notAn' => 'IP' },
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth77')}.to raise_error(Puppet::Error, /(expects a value of type Undef, Stdlib::IP::Address::V6|expects a match for Variant\[Stdlib::IP::Address::V6::Full .*, Stdlib::IP::Address::V6::Compressed)/)
    end
  end

  context 'incorrect value: ipv6address in array' do
    let(:title) { 'eth77' }
    let :params do {
      :ensure      => 'up',
      :ipaddress   => '1.2.3.4',
      :netmask     => '255.255.255.0',
      :ipv6address => [
        '123:4567:89ab:cdef:123:4567:89ab:cdee',
        'notAnIP',
        '123:4567:89ab:cdef:123:4567:89ab:cdef',
      ]
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth77')}.to raise_error(Puppet::Error, /(expects a Stdlib::IP::Address::V6 |expects a match for Variant\[Stdlib::IP::Address::V6::Full .*, Stdlib::IP::Address::V6::Compressed)/)
    end
  end

  context 'required parameters' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure    => 'up',
#      :ipaddress => '1.2.3.4',
#      :netmask   => '255.255.255.0',
    }
    end
    let :facts do {
      :os         => {
        :family => 'RedHat'
      },
      :networking => {
        :interfaces => {
          :eth1 => {
            :mac => 'fe:fe:fe:aa:aa:aa'
          }
        }
      }
    }
    end
    it { should contain_file('ifcfg-eth1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth1',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth1] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=fe:fe:fe:aa:aa:aa',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
#        'IPADDR=1.2.3.4',
#        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { is_expected.to contain_file('ifcfg-eth1').that_notifies('Service[network]') }
  end

  context 'no restart' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
      :restart   => false,
    }
    end
    let :facts do {
      :os         => {
        :family => 'RedHat'
      },
      :networking => {
        :interfaces => {
          :eth1 => {
            :mac => 'fe:fe:fe:aa:aa:aa'
          }
        }
      }
    }
    end
    it { should contain_file('ifcfg-eth1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth1'
    )}
    it 'should contain File[ifcfg-eth1] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=fe:fe:fe:aa:aa:aa',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { is_expected.to_not contain_file('ifcfg-eth1').that_notifies('Service[network]') }
  end

  context 'optional parameters' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure       => 'down',
      :ipaddress    => '1.2.3.4',
      :netmask      => '255.255.255.0',
      :gateway      => '1.2.3.1',
      :macaddress   => 'ef:ef:ef:ef:ef:ef',
      :userctl      => true,
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :peerdns      => true,
      :dns1         => '3.4.5.6',
      :dns2         => '5.6.7.8',
      :domain       => 'somedomain.com',
      :ipv6init     => true,
      :ipv6autoconf => true,
      :ipv6peerdns  => true,
      :ipv6address  => '123:4567:89ab:cdef:123:4567:89ab:cdef/64',
      :ipv6gateway  => '123:4567:89ab:cdef:123:4567:89ab:1',
      :linkdelay    => '5',
      :scope        => 'peer 1.2.3.1',
      :defroute     => 'yes',
      :metric       => '10',
      :zone         => 'trusted',
      :arpcheck     => false,
    }
    end
    let :facts do {
      :os         => {
        :family => 'RedHat'
      },
      :networking => {
        :interfaces => {
          :eth1 => {
            :mac => 'fe:fe:fe:aa:aa:aa'
          }
        }
      }
    }
    end
    it { should contain_file('ifcfg-eth1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth1',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth1] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=ef:ef:ef:ef:ef:ef',
        'ONBOOT=no',
        'HOTPLUG=no',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'GATEWAY=1.2.3.1',
        'MTU=9000',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'PEERDNS=yes',
        'DNS1=3.4.5.6',
        'DNS2=5.6.7.8',
        'DOMAIN="somedomain.com"',
        'USERCTL=yes',
        'IPV6INIT=yes',
        'IPV6_AUTOCONF=yes',
        'IPV6ADDR=123:4567:89ab:cdef:123:4567:89ab:cdef/64',
        'IPV6_DEFAULTGW=123:4567:89ab:cdef:123:4567:89ab:1',
        'IPV6_PEERDNS=yes',
        'LINKDELAY=5',
        'SCOPE="peer 1.2.3.1"',
        'DEFROUTE=yes',
        'ZONE=trusted',
        'METRIC=10',
	'ARPCHECK=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters - vlan' do
    let(:title) { 'eth6.203' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
    }
    end
    let :facts do {
      :os         => {
        :family => 'RedHat'
      },
      :networking => {
        :interfaces => {
          :eth6 => {
            :mac => 'bb:cc:bb:cc:bb:cc'
          }
        }
      }
    }
    end
    it { should contain_file('ifcfg-eth6.203').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth6.203',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth6.203] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth6.203', [
        'DEVICE=eth6.203',
        'BOOTPROTO=none',
        'HWADDR=bb:cc:bb:cc:bb:cc',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters - manage_hwaddr' do
    let(:title) { 'eth0' }
    let :params do {
      :ensure         => 'up',
      :ipaddress      => '1.2.3.4',
      :netmask        => '255.255.255.0',
      :manage_hwaddr  => false,
    }
    end
    let :facts do {
      :os         => {
        :family => 'RedHat'
      },
      :networking => {
        :interfaces => {
          :eth0 => {
            :mac => 'bb:cc:bb:cc:bb:cc'
          }
        }
      }
    }
    end
    it { should contain_file('ifcfg-eth0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth0',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth0] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth0', [
        'DEVICE=eth0',
        'BOOTPROTO=none',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'flush => true - ip addr flush' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
      :flush     => true
    }
    end
    let :facts do {
      :os         => {
        :family => 'RedHat'
      },
      :networking => {
        :interfaces => {
          :eth1 => {
            :mac => 'fe:fe:fe:aa:aa:aa'
          }
        }
      }
    }
    end
    it { should contain_exec('network-flush').with_command('ip addr flush dev eth1').that_comes_before('Service[network]') }
  end

  context 'optional parameters - single ipv6address in array' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure      => 'up',
      :ipaddress   => '1.2.3.4',
      :netmask     => '255.255.255.0',
      :ipv6init    => true,
      :ipv6address => [
        '123:4567:89ab:cdef:123:4567:89ab:cdee',
      ],
    }
    end
    let :facts do {
      :os         => {
        :family => 'RedHat'
      },
      :networking => {
        :interfaces => {
          :eth1 => {
            :mac => 'fe:fe:fe:aa:aa:aa'
          }
        }
      }
    }
    end
    it { should contain_file('ifcfg-eth1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth1',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth1] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=fe:fe:fe:aa:aa:aa',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'IPV6INIT=yes',
        'IPV6ADDR=123:4567:89ab:cdef:123:4567:89ab:cdee',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters - multiple ipv6addresses' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure      => 'up',
      :ipaddress   => '1.2.3.4',
      :netmask     => '255.255.255.0',
      :ipv6init    => true,
      :ipv6address => [
        '123:4567:89ab:cdef:123:4567:89ab:cded',
        '123:4567:89ab:cdef:123:4567:89ab:cdee',
        '123:4567:89ab:cdef:123:4567:89ab:cdef',
      ],
    }
    end
    let :facts do {
      :os         => {
        :family => 'RedHat'
      },
      :networking => {
        :interfaces => {
          :eth1 => {
            :mac => 'fe:fe:fe:aa:aa:aa'
          }
        }
      }
    }
    end
    it { should contain_file('ifcfg-eth1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth1',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth1] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=fe:fe:fe:aa:aa:aa',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'IPV6INIT=yes',
        'IPV6ADDR=123:4567:89ab:cdef:123:4567:89ab:cded',
        'IPV6ADDR_SECONDARIES="123:4567:89ab:cdef:123:4567:89ab:cdee 123:4567:89ab:cdef:123:4567:89ab:cdef"',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end
end
