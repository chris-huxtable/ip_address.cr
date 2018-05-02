# ip_address.cr

Encapsulates IPv4 and IPv6 Addresses and Blocks.

Note: Currently only fully supports IPv4


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
	address0 = IP::Address["127.0.0.128"]
	address1 = IP::Address["10.0.0.0"]?
	address2 = IP::Address.new("127.0.0.0")
	address3 = IP::Address.new?("127.0.0.0")

	block0 = IP::Block["127.0.0.0/8"]
	block1 = IP::Block["10.0.0.0/8"]?
	block2 = IP::Block.new("127.0.0.0/8")
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
