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
require "../../lib_c/arpa/inet"


struct IP::Address::IPv6 < IP::Address

	alias Value = UInt128
	alias Hextet = UInt16
	alias Hextets = Tuple(Hextet, Hextet, Hextet, Hextet, Hextet, Hextet, Hextet, Hextet)

	ADDRESS_MAX = ~0_u128 #0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_u128
	ADDRESS_WIDTH = 128_u8

	# Creates a new `IP::Address::IPv6` from a `{{ Value.id }}` value.
	def initialize(@value : Value)
	end

	# Constructs a new `IP::Address::IPv6` from the contents of a `String`. Expects an
	# address in the standard presentation form XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX
	# or in the compressed from similar to XXXX:XXXX::XXXX:XXXX:XXXX.
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.new(string : String) : self
		return new?(string) || raise MalformedError.new()
	end

	# Constructs a new `IP::Address::IPv6` from the contents of a `String`. Expects an
	# address in the standard presentation form XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX
	# or in the compressed from similar to XXXX:XXXX::XXXX:XXXX:XXXX.
	#
	# Returns `nil` when the input is malformed.
	#
	def self.new?(string : String) : self?
		hextets = Parser.hextets(string)
		return nil if ( !hextets )
		return new(hextets)
	end

	# Constructs a new `IP::Address::IPv6` from a `Tuple` of 8 `UInt16`.
	def self.new(hextets : Hextets)
		offset = (7 * 16).to_u128
		value = 0_u128
		hextets.each() { |group|
			value  += (group.to_u128 << offset )
			offset -= 16
		}

		return new(value)
	end

	# Constructs a new `IP::Address::IPv6` from a `SockaddrIn6*`.
	#
	# TODO: Significant testing nessissary.
	def self.new(sockaddr : LibC::SockaddrIn6*) : self
		v = sockaddr.value
		{% if flag?(:darwin) || flag?(:openbsd) || flag?(:freebsd) %}
			v = v.sin6_addr.__u6_addr.__u6_addr16
		{% elsif flag?(:musl) %}
			v = v.sin6_addr.__in6_union.__s6_addr16
		{% elsif flag?(:gnu) || flag?(:linux) %}
			v = v.sin6_addr.__in6_u.__u6_addr16
		{% end %}

		v.map!() { |group| next LibC.ntohs(group).as(UInt16) }
		return new({ v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7] })
	end

	# Constructs a new `IP::Address::IPv6` from an `Int`.
	def self.new(value : Int) : self
		raise OutOfBoundsError.new("Value #{value} out of bounds. Too high.") if ( value > ADDRESS_MAX )
		raise OutOfBoundsError.new("Value #{value} out of bounds. Too low.")  if ( value < 0 )
		return new(value.to_u128)
	end

	# The internally stored value of the address.
	getter value : Value

	# The internally stored value of the address in network byte order.
	def value_network() : StaticArray(LibC::UInt16T, 8)
		return StaticArray(LibC::UInt16T, 8).new() { |i|
			next LibC.htons(self[i].as(LibC::UInt16T))
		}
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
		return IP::Block.loopback_ipv6().covers?(self)
	end

	# Returns the requested group from the address.
	#
	# Raises `OutOfBoundsError` if the requested group is not [0..7].
	def [](index : Int) : Hextet
		raise OutOfBoundsError.new("Index #{index} out of bounds. Too high.") if ( index > 7 )
		raise OutOfBoundsError.new("Index #{index} out of bounds. Too low.")  if ( index < 0 )

		shift = ((7 - index) * 16).to_u128
		value = ((0xFFFF_u128 << shift) & @value) >> shift
		return value.to_u16
	end

	# Returns a `Tuple` of 8 `UInt16` which represent the addresses octets.
	def hextets() : Hextets
		return { self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7] }
	end

	# Returns the presentation representation of the address as a `String`.
	def to_s(upcase : Bool = false, minify : Bool = true) : String
		return String.build() { |io| to_s(upcase, minify, io) }
	end

	# Appends the presentation representation of the address to the given `IO`.
	def to_s(upcase : Bool, minify : Bool, io : IO) : Nil
		return to_s_minify(upcase, io) if ( minify )

		hextets.each_with_index() { |group, i|
			io << ':' if ( i != 0 )
			string = group.to_s(16, upcase: upcase)
			(4 - string.size).times() { io << '0' }
			io << string
		}
	end

	# :nodoc:
	def to_s(io : IO)
		to_s(false, true, io)
	end

	# :nodoc:
	private def to_s_minify(upcase : Bool, io : IO) : Nil
		streaks = Array(Array(UInt16)|UInt16|Nil).new(8)
		streak : Array(UInt16)? = nil

		hextets.each() { |hextet|
			if ( streak )
				if ( hextet == 0 )
					streak << hextet
					next
				end
				streaks << streak
				streak = nil
				streaks << hextet
			elsif ( hextet == 0 )
				streak = Array(UInt16).new()
				streak << hextet
			else
				streaks << hextet
			end
		}
		streaks << streak if ( streak )

		longest_idx : Int32? = nil
		longest = 0
		streaks.each_with_index() { |e, i|
			next if ( !e.is_a?(Array) )
			length = e.size
			next if ( longest >= length )
			longest = length
			longest_idx = i
		}
		streaks[longest_idx] = nil if ( longest_idx )

		max_idx = streaks.size - 1
		streaks.each_with_index() { |e, i|
			io << ':' if ( i != 0 )
			case e
				when UInt16 then e.to_s(16, io)
				when Nil then io << ':' if ( i == 0 || i == max_idx )
				when Array
					e.each_with_index() { |hextet, i|
						io << ':' if ( i != 0 )
						hextet.to_s(16, io)
					}
			end
		}

		io << ":0" if ( value == 0_u128)
	end

	# Produces the c `sockaddr_in6` struct required by `bind`, `connect`, `sendto`, and `sendmsg`.
	#
	# **Note:** Unix Network Programming: Volume 1, 3rd Edition, p.71-72
	# - sin6_len: default size of this struct is 28 bytes.
	# - sin_zero: is unused.
	#
	# TODO: Set correct scope id
	def to_sockaddr(port : UInt16 = 0_u16) : LibC::Sockaddr*
		sockaddr = uninitialized LibC::SockaddrIn6
		sockaddr.sin6_len                        = 28_u8.as(LibC::UInt8T)
		sockaddr.sin6_family                     = LibC::AF_INET6
		sockaddr.sin6_port                       = LibC.htons(port).as(LibC::UInt16T)
		sockaddr.sin6_flowinfo                   = 0_u32.as(LibC::UInt32T)
		sockaddr.sin6_scope_id                   = 0_u32.as(LibC::UInt32T)

		{% if flag?(:darwin) || flag?(:openbsd) || flag?(:freebsd) %}
			sockaddr.sin6_addr.__u6_addr.__u6_addr16 = value_network
		{% elsif flag?(:musl) %}
			sockaddr.sin6_addr.__in6_union.__s6_addr16 = value_network
		{% elsif flag?(:gnu) || flag?(:linux) %}
			sockaddr.sin6_addr.__in6_u.__u6_addr16 = value_network
		{% end %}


		ptr = Pointer(LibC::SockaddrIn6).malloc()
		ptr.copy_from(pointerof(sockaddr), 1)
		return ptr.as(LibC::Sockaddr*)
	end


	# :nodoc:
	private class Parser < Address::Parser

		SEPARATOR = ':'

		def self.hextets(string : String) : Hextets?
			return nil if ( string.empty? || !string.ascii_only? )
			return new(string).hextets
		end

		protected def next_value() : Hextet?
			hextet = read_hex(SEPARATOR)
			return nil if ( !hextet || hextet > 0xFFFF )
			return hextet.to_u16
		end

		protected def hextets() : Hextets?
			left = Array(Hextet).new(8)
			right = nil

			8.times { |count|
				if ( char?(SEPARATOR) && !right )
					right = Array(Hextet).new(8)

					if ( left.empty? )
						return nil if ( !has_next?() )
						return nil if ( next_char != SEPARATOR )
					end

					next_char
					break if ( !has_next?() )
				end

				hextet = next_value()
				return nil if ( hextet.nil? )
				( right ) ? right << hextet : left << hextet

				break if ( at_end?() )
				return nil if ( !char?(SEPARATOR) || !has_next?() )
				next_char()
			}

			if ( left.empty? && right )
				return { 0_u16, 0_u16, 0_u16, 0_u16, 0_u16, 0_u16, 0_u16, 0_u16 } if ( right.empty? )
				return nil if ( right.size == 8 )
			end

			if ( right )
				diff = 8 - (left.size + right.size)
				return nil if ( diff < 0 )

				diff.times() { left << 0_u16 }
				right.each() { |elm| left << elm }
			end

			return nil if left.size != 8
			return nil if has_next?()
			return { left[0], left[1], left[2], left[3], left[4], left[5], left[6], left[7] }
		end

	end

end
