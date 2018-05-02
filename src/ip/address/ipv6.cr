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

	ADDRESS_MAX = 0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_u128
	ADDRESS_WIDTH = 128_u8

	# :nodoc:
	enum Minification
		None
		Simple
		Agressive
	end

	# Creates a new `IP::Address::IPv6` from a `UInt128` value.
	def initialize(@value : UInt128)
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
		groups = Parser.groups(string)
		return nil if ( !groups )
		return new(groups)
	end

	# Constructs a new `IP::Address::IPv6` from a `Tuple` of 8 `UInt16`.
	def self.new(groups : Tuple(UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16))
		offset = (7 * 16).to_u128
		value = 0_u128
		groups.each() { |group|
			value  += (group.to_u128 << offset )
			offset -= 16
		}

		return new(value)
	end

	# Constructs a new `IP::Address::IPv6` from a `SockaddrIn6*`.
	#
	# TODO: Significant testing nessissary.
	def self.new(sockaddr : LibC::SockaddrIn6*) : self
		v = sockaddr.value.sin6_addr.__u6_addr.__u6_addr16
		v = v.map() { |group| next LibC.ntohs(group).as(UInt16) }
		return new({ v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7] })
	end

	# Constructs a new `IP::Address::IPv6` from an `Int`.
	def self.new(value : Int) : self
		raise OutOfBoundsError.new("Value #{value} out of range. Too high.") if ( value > ADDRESS_MAX )
		raise OutOfBoundsError.new("Value #{value} out of range. Too low.")  if ( value < 0 )
		return new(value.to_u128)
	end

	# The internally stored value of the address.
	getter value : UInt128

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
	def max_address() : UInt128
		return ADDRESS_MAX
	end

	# Informs if the address is IPv6 or not.
	def ipv6?() : Bool
		return true
	end

	# Informs if the address is in the loopback address space or not.
	def loopback?() : Bool
		return IP::Block.loopback_ipv6().covers?(self)
	end

	# Returns the requested group from the address.
	#
	# Raises `OutOfBoundsError` if the requested group is not [0..7].
	def [](index : Int) : UInt16
		raise OutOfBoundsError.new("Index #{index} is out of bounds.") if ( index > 7 || index < 0)

		shift = ((7 - index) * 16).to_u128
		value = ((0xFFFF_u128 << shift) & @value) >> shift
		return value.to_u16
	end

	# Returns a `Tuple` of 8 `UInt16` which represent the addresses octets.
	def groups() : Tuple(UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16)
		return { self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7] }
	end

	# Returns the presentation representation of the address as a `String`.
	#
	# `Minification`
	# - `None`
	# - `Simple`
	# - `Agressive`
	def to_s(upcase : Bool = false, minify : Minification = Minification::Simple) : String
		return String.build() { |io| to_s(upcase, minify, io) }
	end

	# Appends the presentation representation of the address to the given `IO`.
	#
	# `Minification`
	# - `None`
	# - `Simple`
	# - `Agressive`
	def to_s(upcase : Bool, minify : Minification, io : IO) : Nil
		return to_s_mini_simple(upcase, io) if ( minify.simple? )
		return to_s_mini_aggressive(upcase, io) if ( minify.agressive? )

		groups.each_with_index() { |group, i|
			io << ':' if ( i != 0 )
			string = group.to_s(16, upcase: upcase)
			(4 - string.size).times() { io << '0' }
			io << string
		}
	end

	# :nodoc:
	def to_s(io : IO)
		to_s(false, Minification::Simple, io)
	end

	# :nodoc:
	private def to_s_mini_simple(upcase : Bool, io : IO) : Nil
		state = :fresh
		io << ':' if ( groups.first == 0 )
		groups.each_with_index() { |group, i|
			if ( state == :in )
				if ( group == 0 )
					io << ':' if ( i == groups.size - 1 )
					next
				end

				state = :finished
			end

			io << ':' if ( i != 0 )

			if ( state == :fresh && group == 0 )
				state = :in
				next
			end

			string = group.to_s(16, upcase: upcase)
			io << string
		}
		io << '0' if ( value == 0_u128)
	end

	# :nodoc:
	private def to_s_mini_aggressive(upcase : Bool, io : IO) : Nil
		streaks = Array(Array(UInt16)|UInt16|Nil).new(8)
		streak : Array(UInt16)? = nil

		groups.each() { |group|
			if ( streak )
				if ( group == 0 )
					streak << group
					next
				end
				streaks << streak
				streak = nil
				streaks << group
			elsif ( group == 0 )
				streak = Array(UInt16).new()
				streak << group
			else
				streaks << group
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
				when Array then e.each_with_index() { |e, i| e.to_s(16, io) }
				when UInt16 then e.to_s(16, io)
				when Nil
					io << ':' if ( i == 0 || i == max_idx )
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
		sockaddr.sin6_addr.__u6_addr.__u6_addr16 = value_network
		sockaddr.sin6_scope_id                   = 0_u32.as(LibC::UInt32T)

		ptr_sockaddr = Pointer(LibC::SockaddrIn6).malloc()
		ptr_sockaddr.copy_from(pointerof(sockaddr), 1)
		return ptr_sockaddr.as(LibC::Sockaddr*)
	end


	# :nodoc:
	private class Parser

		SEPARATOR = ':'
		NULL = '\0'
		A_LOWER = 'a' - 10
		A_UPPER = 'A' - 10

		def self.groups(string : String) : Tuple(UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16)?
			return nil if ( string.empty? )
			return nil if ( !string.ascii_only? )

			return new(string).groups
		end

		private def initialize(string : String)
			@cursor = Char::Reader.new(string)
		end

		protected def hex_char(char : Char)
			return (char - '0') if ( char.number? )
			return (char - A_LOWER) if ( 'a' <= char <= 'f' )
			return (char - A_UPPER) if ( 'A' <= char <= 'F' )
			return nil
		end

		protected def hex_char?(char : Char)
			return true if ( char.number? )
			return true if ( 'a' <= char <= 'f' )
			return true if ( 'A' <= char <= 'F' )
			return false
		end

		protected def next_group() : UInt16?
			char = @cursor.current_char
			return nil if ( !hex_char?(char) )

			octet = 0_u32
			count = 0

			loop {
				return nil if ( count > 4 )
				break if ( char == SEPARATOR )

				value = hex_char(char)
				return nil if ( !value )
				octet *= 16
				octet += value

				break if ( !@cursor.has_next? )
				char = @cursor.next_char()
				break if ( count == 4 || char == NULL )
				count += 1
			}

			return nil if ( octet > 0xFFFF )
			return octet.to_u16
		end

		protected def groups() : Tuple(UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16)?
			groups = Slice[0_u16, 0_u16, 0_u16, 0_u16, 0_u16, 0_u16, 0_u16, 0_u16]
			idx = 0_i8

			loop {
				return nil if ( idx > 7 )
				group = next_group()

				return nil if ( group.nil? )
				groups[idx] = group

				char = @cursor.current_char
				break if ( char == NULL )
				return nil if ( char != SEPARATOR || !@cursor.has_next? )

				char = @cursor.next_char()
				#if ( char == ':' )

				idx += 1
			}

			return nil if ( @cursor.current_char() != NULL )

			return { groups[0], groups[1], groups[2], groups[3], groups[4], groups[5], groups[6], groups[7] }
		end

	end

end
