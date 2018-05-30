# ip_address.cr
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://chris-huxtable.github.io/ip_address.cr/)
[![GitHub release](https://img.shields.io/github/release/chris-huxtable/ip_address.cr.svg)](https://github.com/chris-huxtable/ip_address.cr/releases)
[![Build Status](https://travis-ci.org/chris-huxtable/ip_address.cr.svg?branch=master)](https://travis-ci.org/chris-huxtable/ip_address.cr)

Encapsulates IPv4 and IPv6 Addresses and Blocks.


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  ip_address:
    github: chris-huxtable/ip_address.cr
```


## Usage

```crystal
require "ip_address"
```

Some samples:
```crystal
address0 = IP["127.0.0.128"]
address1 = IP["10.0.0.0"]?
address2 = IP.new("127.0.0.0")
address3 = IP.new?("127.0.0.0")

address4 = IP["2001:0db8:123:4567:89ab:cdef:1234:5678"]
address5 = IP::Address["1::2"]?
address6 = IP.new("::1")
address7 = IP::Address.new?("::0")

block0 = IP["127.0.0.0/8"]
block1 = IP::Block["10.0.0.0/8"]?
block2 = IP.new("127.0.0.0/8")
block3 = IP::Block.new?("127.0.0.0/8")

block0 = IP["127.0.0.0/8"]
block1 = IP::Block["10.0.0.0/8"]?
block2 = IP.new("127.0.0.0/8")
block3 = IP::Block.new?("127.0.0.0/8")

loopback = IP::Address::IPv4.loopback

block0.includes?(address0)
```


## Contributing

1. Fork it ( https://github.com/chris-huxtable/ip_address.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## Contributors

- [Chris Huxtable](https://github.com/chris-huxtable) - creator, maintainer
