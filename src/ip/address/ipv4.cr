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

require "c/netinet/*"
require "c/arpa/*"

require "../../lib_c/arpa/inet"


struct IP::Address::IPv4 < IP::Address

	alias Value = UInt32
	alias Octet = UInt8
	alias Octets = Tuple(Octet, Octet, Octet, Octet)

	ADDRESS_MAX = 0xFFFF_FFFF_u32
	ADDRESS_WIDTH = 32_u8


	# Creates a new `IP::Address::IPv4` from a `{{ Value.id }}` value.
	def initialize(@value : Value)
	end

	# Constructs a new `IP::Address::IPv4` from the contents of a `String`. Expects an address
	# in the form of [0-255].[0-255].[0-255].[0-255].
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.new(string : String) : self
		return new?(string) || raise MalformedError.new()
	end

	# Constructs a new `IP::Address::IPv4` from the contents of a `String`. Expects an address
	# in the form of [0-255].[0-255].[0-255].[0-255].
	#
	# Returns `nil` when the input is malformed.
	def self.new?(string : String) : self?
		octets = Parser.octets(string)
		return nil if ( !octets )
		return new(octets)
	end

	# Constructs a new `IP::Address::IPv4` from a `Tuple` of 4 `UInt8`.
	def self.new(octets : Octets) : self
		value  = 0_u32
		value += (octets[0].to_u32 << 24 )
		value += (octets[1].to_u32 << 16 )
		value += (octets[2].to_u32 << 8 )
		value += octets[3]

		return new(value)
	end

	# Constructs a new `IP::Address::IPv4` from a `SockaddrIn*`.
	def self.new(sockaddr : LibC::SockaddrIn*) : self
		v = sockaddr.value.sin_addr.s_addr.as(Value)
		return new(LibC.ntohl(v).as(Value))
	end

	# Constructs a new `IP::Address::IPv4` from an `Int`.
	def self.new(value : Int) : self
		raise OutOfBoundsError.new("Value #{value} out of range. Too high.") if ( value > ADDRESS_MAX )
		raise OutOfBoundsError.new("Value #{value} out of range. Too low.")  if ( value < 0 )
		return new(value.to_u32)
	end

	# The internally stored value of the address.
	getter value : Value

	# The internally stored value of the address in network byte order.
	def value_network() : LibC::UInt32T
		return LibC.htonl(value.as(LibC::UInt32T))
	end

	# The width of the address type.
	def width() : UInt8
		return ADDRESS_WIDTH
	end

	# The maximum address of this type.
	def max_value() : Value
		return ADDRESS_MAX
	end

	# Informs if the address is in the loopback address space or not.
	def loopback?() : Bool
		return IP::Block.loopback_ipv4().covers?(self)
	end

	# Returns the requested octet from the address.
	#
	# Raises `OutOfBoundsError` if the requested octet is not [0..3].
	def [](index : Int) : UInt8
		raise OutOfBoundsError.new("Index #{index} out of bounds. Too high.") if ( index > 3 )
		raise OutOfBoundsError.new("Index #{index} out of bounds. Too low.")  if ( index < 0 )

		shift = (32 - ((index + 1) * 8))
		value = ((0xFF << shift) & @value) >> shift
		return value.to_u8
	end

	# Returns a `Tuple` of 4 `UInt8` which represent the addresses octets.
	def octets() : Octets
		return { self[0], self[1], self[2], self[3] }
	end

	# Appends the presentation representation of the address to the given `IO`.
	def to_s(io : IO)
		io << self[0] << '.' << self[1] << '.' << self[2] << '.' << self[3]
	end

	# Produces the c `sockaddr_in` struct required by `bind`, `connect`, `sendto`, and `sendmsg`.
	#
	# **Note:** Unix Network Programming: Volume 1, 3rd Edition, p.68
	# - sin_len: default size of this struct is 16 bytes. Is set internally when passed though `bind`,
	# `connect`, `sendto`, or `sendmsg`.
	# - sin_zero: is unused.
	def to_sockaddr(port : UInt16 = 0_u16) : LibC::Sockaddr*
		sockaddr = uninitialized LibC::SockaddrIn
		sockaddr.sin_len         = 16_u8.as(LibC::UInt8T)
		sockaddr.sin_family      = LibC::AF_INET
		sockaddr.sin_port        = LibC.htons(port).as(LibC::UInt16T)
		sockaddr.sin_addr.s_addr = value_network

		ptr_sockaddr = Pointer(LibC::SockaddrIn).malloc()
		ptr_sockaddr.copy_from(pointerof(sockaddr), 1)
		return ptr_sockaddr.as(LibC::Sockaddr*)
	end


	# :nodoc:
	private class Parser < Address::Parser

		SEPARATOR = '.'

		def self.octets(string : String) : Octets?
			return nil if ( string.empty? || !string.ascii_only? )
			return new(string).octets
		end

		protected def next_value() : Octet?
			octet = read_int(SEPARATOR)
			return nil if ( !octet || octet > 255 )
			return octet.to_u8
		end

		protected def octets() : Octets?
			octets = Slice[0_u8, 0_u8, 0_u8, 0_u8]

			4.times { |count|
				octet = next_value()

				return nil if ( octet.nil? )
				octets[count] = octet

				break if ( at_end?() )
				return nil if ( !char?(SEPARATOR) || !has_next?() )
				next_char()
			}

			return nil if has_next?()
			return { octets[0], octets[1], octets[2], octets[3] }
		end

	end

end
