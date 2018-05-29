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


abstract struct IP::Address

	include Comparable(IP::Address)

	# Constructs a new IPv4 or IPv6 `IP::Address` by interpreting  the contents of a `String`.
	#
	# Expects an address in the form of [0-255].[0-255].[0-255].[0-255],
	# XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX, or XXXX:XXXX::XXXX:XXXX:XXXX.
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.[](string : String) : self
		return new(string)
	end

	# ditto
	def self.new(string : String) : self
		return new?(string) || raise MalformedError.new()
	end

	# Constructs a new IPv4 or IPv6 `IP::Address` by interpreting  the contents of a `String`.
	#
	# Expects an address in the form of [0-255].[0-255].[0-255].[0-255],
	# XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX, or XXXX:XXXX::XXXX:XXXX:XXXX.
	#
	# Returns `nil` when the input is malformed.
	def self.[]?(string : String) : self?
		return new?(string)
	end

	# ditto
	def self.new?(string : String) : self?
		return nil if ( string.empty?() )
		return IPv4.new?(string) if ( string.count('.') == 3 )
		return IPv6.new?(string) if ( string.count(':') > 1 )
		return nil
	end

	# Constructs a new IPv4 `IP::Address` from the contents of a `String`.
	#
	# Expects an address in the form of [0-255].[0-255].[0-255].[0-255].
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.ipv4(string : String)
		return IPv4.new(string)
	end

	# Constructs a new IPv4 `IP::Address` from the contents of a `String`.
	#
	# Expects an address in the form of [0-255].[0-255].[0-255].[0-255].
	#
	# Returns `nil` when the input is malformed.
	def self.ipv4?(string : String)
		return IPv4.new?(string)
	end

	# Constructs a new IPv6 `IP::Address` from the contents of a `String`.
	#
	# Expects an address in the standard presentation form
	# XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX  or in the compressed from
	# similar to XXXX:XXXX::XXXX:XXXX:XXXX.
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.ipv6(string : String)
		return IPv6.new(string)
	end

	# Constructs a new IPv6 `IP::Address` from the contents of a `String`.
	#
	# Expects an address in the standard presentation form
	# XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX or in the compressed from
	# similar to XXXX:XXXX::XXXX:XXXX:XXXX.
	#
	# Returns `nil` when the input is malformed.
	def self.ipv6?(string : String)
		return IPv6.new?(string)
	end

	# Creates an `IP::Address` from the internal OS representation of a Socket Address.
	def self.new(sockaddr : LibC::Sockaddr*) : self
		family = sockaddr.value.sa_family
		case ( family )
			when LibC::AF_INET then return IPv4.new(sockaddr.as(LibC::SockaddrIn*))
			when LibC::AF_INET6 then return IPv6.new(sockaddr.as(LibC::SockaddrIn6*))
		end
		raise "Unsupported family type: #{family}"
	end

	# The internally stored value of the address.
	abstract def value

	# The internally stored value of the address in network byte order.
	abstract def value_network()

	# The width of the address type.
	abstract def width

	# The maximum address of this type.
	abstract def max_value

	# Informs if the address is IPv4 or not.
	def ipv4?() : Bool
		return is_a?(IP::Address::IPv4)
	end

	# Informs if the address is IPv6 or not.
	def ipv6?() : Bool
		return is_a?(IP::Address::IPv6)
	end

	# Returns the `Socket::Family` associated with this address.
	def family() : Socket::Family
		return case
			when ipv4? then Socket::Family::INET
			when ipv6? then Socket::Family::INET6
			else Socket::Family::UNSPEC
		end
	end

	# Informs if the address is in the loopback address space or not.
	abstract def loopback?() : Bool

	# Returns the requested component from the address.
	abstract def [](index : Int)

	# Generates a new `IP::Address` with a given integer offset.
	def +(other : Int) : self
		return self - (other * -1)  if ( other < 0 )
		new_value = value + other
		return self.class.new(new_value) if ( new_value > value )
		raise OverflowError.new()
	end

	# ditto
	def -(other : Int) : self
		return self + (other * -1) if ( other < 0 )
		new_value = value - other
		return self.class.new(new_value) if ( new_value < value )
		raise UnderflowError.new()
	end

	# See `Object#hash(hasher)`
	def hash(hasher)
		value.hash(hasher)
	end

	# Compares this address with another, returning `-1`, `0` or `+1` depending if the
	# address is less, equal or greater than the *other* address.
	def <=>(other : IP::Address) : Int
		return ( value <=> other.value )
	end

	# Compares this address with another address, indicating if they are adjacent.
	#
	# Adjacency is when there are no addresses between the address and the other address
	# and the two addresses are not the same.
	def adjacent?(other : IP::Address)
		return true if ( value > other.value && (value == other.value + 1) )
		return true if ( value < other.value && (value == other.value - 1) )
		return false
	end

	# Appends a type-specified presentation representation of the address to the
	# given `IO`.
	def inspect(io : IO) : Nil
		self.class.to_s(io)
		io << '('
		to_s(io)
		io << ')'
	end

	abstract def to_sockaddr()

	# :nodoc:
	class MalformedError < Exception
		def new()
			return new("The address was malformed.")
		end
	end

	# :nodoc:
	class OverflowError < Exception
		def new()
			return new("The resultant address overflows.")
		end
	end

	# :nodoc:
	class UnderflowError < Exception
		def new()
			return new("The resultant address underflows")
		end
	end

	# :nodoc:
	class OutOfBoundsError < Exception; end


	# :nodoc:
	abstract class Parser

		NULL = '\0'

		private def initialize(string : String)
			@cursor = Char::Reader.new(string)
		end


		# MARK: - Queries

		protected delegate(current_char, to: @cursor)
		protected delegate(next_char, to: @cursor)
		protected delegate(has_next?, to: @cursor)

		protected def next_char?() : Char?
			return nil if ( !has_next? )
			return next_char()
		end

		protected def at_end?() : Bool
			return ( current_char() == NULL )
		end

		protected def char?(char : Char?) : Bool
			return false if ( !char )
			return ( current_char() == char )
		end


		# MARK: - Reading

		protected def read_int(terminator : Char, limit : UInt8 = 3_u8) : UInt32?
			char = current_char
			return nil if ( !char.ascii_number? )

			value = 0_u32
			loop {
				break if ( char == terminator )

				return nil if ( !char.ascii_number? )
				value *= 10_u32
				value += char.to_i()

				break if ( !has_next?() )
				char = next_char()

				break if ( limit <= 0 || char == NULL )
				limit -= 1
			}

			return value
		end

		protected def read_hex(terminator : Char, limit : UInt8 = 4_u8) : UInt32?
			char = current_char
			return nil if ( !char.hex? )

			value = 0_u32
			loop {
				break if ( char == terminator )

				return nil if ( !char.hex? )
				value *= 16_u32
				value += char.to_i(16)

				break if ( !has_next?() )
				char = next_char()

				break if ( limit <= 0 || char == NULL )
				limit -= 1
			}

			return value
		end

	end

end

require "./block"

abstract struct IP::Address

	include Comparable(IP::Block)

	# Compares this address to a given `IP::Block` returning `true` if the address falls
	# after the block.
#	def >(other : IP::Block)
#		return ( value > other.last.value )
#	end

	# Compares this address to a given `IP::Block` returning `true` if the address falls
	# inside or after the block.
#	def >=(other : IP::Block)
#		return ( value >= other.first.value )
#	end

	# Compares this address to a given `IP::Block` returning `true` if the address falls
	# before the block.
#	def <(other : IP::Block)
#		return ( value < other.first.value )
#	end

	# Compares this address to a given `IP::Block` returning `true` if the address falls
	# inside or before the block.
#	def <=(other : IP::Block)
#		return ( value <= other.last.value )
#	end

	# Compares this address with block, returning `-1`, `0` or `+1` depending if the
	# address is less than, included in, or greater than the *other* block.
	def <=>(other : IP::Block) : Int
		return 0 if other.includes?(self)
		return ( self <=> other.first )
	end

	# Compares this address with an `IP::Block`, indicating if they are adjacent.
	#
	# Adjacency is when there are no addresses between the address and the other address
	# block and the address is not included in the block.
	def adjacent?(other : IP::Block)
		return true if ( value > last_value && (value == last_value + 1) )
		return true if ( value < first_value && (value == first_value - 1) )
		return false
	end

end

require "./address/*"
