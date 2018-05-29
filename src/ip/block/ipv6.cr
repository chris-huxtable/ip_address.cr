# Copyright (c) 2018 Christian Huxtable <chris@huxtable.ca>.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


struct IP::Block::IPv6 < IP::Block

	private LOOPBACK = 0x0000_0000_0000_0000_0000_0000_0000_0000_u128
	private LOOPBACK_COUNT = 1_u8

	# :nodoc:
	private def initialize(@address : IP::Address::IPv6, @block : UInt8, @size : UInt128)
	end

	# Constructs a new `IP::Block::IPv6` by interpreting the contents of a given `String`.
	#
	# Expects a definition in CIDR notation similar to XXXX:XXXX::XXXX:XXXX:XXXX/[0-128], or
	# XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX/[0-128].
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.new(string : String) : self
		return new?(string) || raise MalformedError.new()
	end

	# Constructs a new `IP::Block::IPv6` by interpreting the contents of a given `String`.
	#
	# Expects a definition in CIDR notation similar to XXXX:XXXX::XXXX:XXXX:XXXX/[0-128], or
	# XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX/[0-128].
	#
	# Returns `nil` when the input is malformed.
	def self.new?(string : String) : self?
		return nil if ( string.empty? )
		return nil if ( !string.ascii_only? )

		part = string.split('/')
		return nil if ( part.size() != 2 )

		block = part.last()
		return nil if ( block.empty? )

		address = IP::Address::IPv6.new?(part.first())
		return nil if ( !address )

		return new?(address, block.to_u8)
	end

	# Constructs a new `IP::Block::IPv6` from an address and the block size, [0-128].
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.new(address : IP::Address::IPv6, block : Int) : self
		return new?(address, block) || raise MalformedError.new()
	end

	# Constructs a new `IP::Block::IPv6` from an address and the block size, [0-128].
	#
	# Returns `nil` when the input is malformed.
	def self.new?(address : IP::Address::IPv6, block : Int) : self?
		return nil if ( block < 0 )
		return nil if ( block > IP::Address::IPv6::ADDRESS_WIDTH )

		size = (2**(IP::Address::IPv6::ADDRESS_WIDTH - block))
		return nil if ((IP::Address::IPv6::ADDRESS_MAX - size + 1) < address.value)

		return new(address, block.to_u8, size.to_u128)
	end

	# Constructs a `IP::Block:IPv6` representing the IPv6 loopback block.
	def self.loopback() : self
		return new(IP::Address::IPv6.new(LOOPBACK), 128_u8, LOOPBACK_COUNT)
	end

	# Returns the address component of the block which is also the first address.
	getter address : IP::Address::IPv6

	# Returns 'block' size in the form of 2^x, x being the 'size'.
	getter block : UInt8

	# Returns the size of the block in terms of number of addresses.
	getter size : UInt128

	# Informs if the block is IPv6 or not.
	def ipv6?() : Bool
		return true
	end

end
