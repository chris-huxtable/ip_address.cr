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


struct IP::Block::IPv4 < IP::Block

	private LOOPBACK = 0x7F_00_00_00_u32 # 2_130_706_432_u32
	private LOOPBACK_COUNT = 16_777_216_u32

	# :nodoc:
	private def initialize(@address : IP::Address::IPv4, @block : UInt8, @size : UInt32)
	end

	# Constructs a new `IP::Block::IPv4` by interpreting the contents of a given `String`.
	#
	# Expects a definition in CIDR notation similar to [0-255].[0-255].[0-255].[0-255]/[0-32].
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.new(string : String) : self
		return new?(string) || raise MalformedError.new()
	end

	# Constructs a new `IP::Block::IPv4` by interpreting the contents of a given `String`.
	#
	# Expects a definition in CIDR notation similar to [0-255].[0-255].[0-255].[0-255]/[0-32]
	#
	# Returns `nil` when the input is malformed.
	def self.new?(string : String) : self?
		return nil if ( string.empty? )
		return nil if ( !string.ascii_only? )

		part = string.split('/')
		return nil if ( part.size() != 2 )

		block = part.last()
		return nil if ( block.empty? )

		address = IP::Address::IPv4.new?(part.first())
		return nil if ( !address )

		block = block.to_u8(whitespace: false) { return nil }
		return new?(address, block)
	end

	# Constructs a new `IP::Block::IPv4` from an address and the block size, [0-32].
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.new(address : IP::Address::IPv4, block : Int) : self
		return new?(address, block) || raise MalformedError.new()
	end

	# Constructs a new `IP::Block::IPv4` from an address and the block size, [0-32].
	#
	# Returns `nil` when the input is malformed.
	def self.new?(address : IP::Address::IPv4, block : Int) : self?
		return nil if ( block < 0 )
		return nil if ( block > IP::Address::IPv4::ADDRESS_WIDTH )

		size = (2**(IP::Address::IPv4::ADDRESS_WIDTH - block))
		return nil if ((IP::Address::IPv4::ADDRESS_MAX - size + 1) < address.value)

		return new(address, block.to_u8, size.to_u32)
	end

	# Constructs a `IP::Block:IPv4` representing the IPv4 loopback block.
	def self.loopback() : self
		return new(IP::Address::IPv4.new(LOOPBACK), 8_u8, LOOPBACK_COUNT)
	end

	# Returns the address component of the block which is also the first address.
	getter address : IP::Address::IPv4

	# Returns 'block' size in the form of 2^x, x being the 'size'.
	getter block : UInt8

	# Returns the size of the block in terms of number of addresses.
	getter size : UInt32

	# Informs if the block is IPv4 or not.
	def ipv4?() : Bool
		return true
	end

end
