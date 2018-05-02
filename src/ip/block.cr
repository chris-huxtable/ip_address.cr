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

abstract struct IP::Block
end

require "./address"

abstract struct IP::Block
	include Comparable(IP::Address)

	# Constructs a new `IP::Block` by interpreting the contents of a given `String`.
	#
	# Expects a definition in CIDR notation similar to [0-255].[0-255].[0-255].[0-255]/[0-32],
	# XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX/[0-128], or XXXX:XXXX::XXXX:XXXX:XXXX/[0-128].
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.[](string : String) : self
		return new(string)
	end

	# ditto
	def self.new(string : String) : self
		return new?(string) || MalformedError.new()
	end

	# Constructs a new `IP::Block` by interpreting the contents of a given `String`.
	#
	# Expects a definition in CIDR notation similar to [0-255].[0-255].[0-255].[0-255]/[0-32],
	# XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX/[0-128], or XXXX:XXXX::XXXX:XXXX:XXXX/[0-128].
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

	# Constructs a new `IP::Block` from an address and block size.
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.new(address : IP::Address, block : Int) : self?
		return new?(address, block) || raise MalformedError.new()
	end

	# ditto
	def self.new?(address : IP::Address, block : Int) : self?
		case address
			when IP::Address::IPv4 then return IPv4.new?(address, block)
			when IP::Address::IPv6 then return IPv6.new?(address, block)
		end
		return nil
	end

	# Constructs a new IPv4 `IP::Block` by interpreting the contents of a given `String`.
	#
	# Expects a definition in CIDR notation similar to [0-255].[0-255].[0-255].[0-255]/[0-32].
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.ipv4(string : String) : self
		return IPv4.new(string)
	end

	# Constructs a new IPv4 `IP::Block` by interpreting the contents of a given `String`.
	#
	# Expects a definition in CIDR notation similar to [0-255].[0-255].[0-255].[0-255]/[0-32].
	#
	# Returns `nil` when the input is malformed.
	def self.ipv4?(string : String) : self?
		return IPv4.new?(string)
	end

	# Constructs a new IPv6 `IP::Block` by interpreting the contents of a given `String`.
	#
	# Expects a definition in CIDR notation similar to
	# XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX/[0-128], or XXXX:XXXX::XXXX:XXXX:XXXX/[0-128].
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.ipv6(string : String) : self
		return IPv6.new(string)
	end

	# Constructs a new IPv6 `IP::Block` by interpreting the contents of a given `String`.
	#
	# Expects a definition in CIDR notation similar to
	# XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX/[0-128], or XXXX:XXXX::XXXX:XXXX:XXXX/[0-128].
	#
	# Returns `nil` when the input is malformed.
	def self.ipv6?(string : String) : self?
		return IPv6.new?(string)
	end

	# Constructs a `IP::Block:IPv4` representing the IPv4 loopback block.
	def self.loopback_ipv4() : self
		return IPv4.loopback()
	end

	# Constructs a `IP::Block:IPv4` representing the IPv4 loopback block.
	def self.loopback_ipv6() : self
		#return IPv6.loopback()
	end

	# Returns the address component of the block which is also the first address.
	abstract def address

	# Returns 'block' size in the form aof 2^x, x being the 'size'.
	abstract def block

	# Returns the size of the block in terms of number of addresses.
	abstract def size

	# Returns the first address in the block.
	def first() : IP::Address
		return address
	end

	# Returns the last address in the block.
	def last() : IP::Address
		return address if ( single_address? )
		return address + (size - 1)
	end

	# Returns the blocks mask.
	def mask() : IP::Address
		return address.class.new(address.max_address() - size() + 1)
	end

	# Informs if the block is IPv4 or not.
	def ipv4?() : Bool
		return false
	end

	# Informs if the block is IPv6 or not.
	def ipv6?() : Bool
		return false
	end

	# Informs if the block is a single address or not.
	def single_address?() : Bool
		return ( block == address.width )
	end

	# Returns a `Bool` indicating if the receiver 'covers' *other*. That is to say the receiver
	# completely includes *other*.
	def covers?(other : IP::Block) : Bool
		return ( (last >= other.last) && (first <= other.first) )
	end

	# ditto
	def covers?(other : IP::Address) : Bool
		return ( (first <= other) && (last >= other) )
	end

	# Returns a `Bool` indicating if the receiver 'intersects' *other*. That is to say the receiver
	# partially includes *other*.
	def intersects?(other : IP::Block) : Bool
		first = first()
		last = last()
		other_last = other.last

		return true if ( last >= other_last && first <= other.first )
		return true if ( ( last >= other.first ) && ( first <= other.first ) )
		return true if ( ( first <= other_last ) && ( last >= other_last ) )
		return false
	end

	# ditto
	def intersects?(other : IP::Address) : Bool
		return covers?(other)
	end

	# Returns a `Bool` indicating if the receiver is 'adjacent' to *other*. That is to
	# say the receiver is immidiatly beside, but not intersecting *other*.
	def adjacent?(other : IP::Block) : Bool
		return ((first.value == other.last.value + 1) || (last.value == other.first.value - 1) )
	end

	# ditto
	def adjacent?(other : IP::Address) : Bool
		return ( (first.value == other.value + 1) || (last.value == other.value - 1) )
	end

	# Returns a `Bool` indicating if the receiver 'includes' the *other* address.
	def includes?(other : IP::Address) : Bool
		return covers?(other)
	end

	# Yield each address to the block.
	def each(&block : IP::Address -> Nil) : Nil
		first_addr = first()
		count.times { |offset| yield(first_addr + offset) }
	end

	# See `Object#hash(hasher)`
	def hash(hasher)
		address.hash(hasher)
		block.hash(hasher)
	end

	# Compares this block to *other* returning `true` if the *other* block falls after the
	# block.
	def >(other : IP::Block)
		return ( last > other.first )
	end

	# Compares this block to *other* returning `true` if the *other* block falls after or
	# inside the block.
	def >=(other : IP::Block)
		return ( last >= other.last )
	end

	# Compares this block to *other* returning `true` if the *other* block falls before the
	# block.
	def <(other : IP::Block)
		return ( first < other.last )
	end

	# Compares this block to *other* returning `true` if the *other* block falls before or
	# inside the block.
	def <=(other : IP::Block)
		return ( first <= other.first )
	end

	# Compares this block to *other* returning `true` if the *other* block is equal to the
	# receiver.
	def ==(other : IP::Block)
		return ( first == other.first && size == other.size )
	end

	# Compares this block with address, returning `-1`, `0` or `+1` depending if the
	# block is less than, inclusive of, or greater than the *other* address.
	def <=>(other : IP::Address) : Int
		return 0 if self.includes?(other)
		return ( first <=> other )
	end

	# Compares this block with the *other* block, returning `-1`, `0` or `+1` depending
	# if the block is less than, inclusive of, or greater than the *other* block.
	#
	# Note: This is slightly different then the comparitors due to the added complexity
	# of a range of values. This is effective for ordering, not comparing inclusivity.
	# As such this object does not include `Comparable` for `IP::Block`s and the comparative
	# operators are added manually.
	def <=>(other : IP::Block) : Int
		return 0 if ( first == other.first && size == other.size )
		return ( first <=> other.first )
	end

	# Appends a type-specified presentation representation of the block to the
	# given `IO`.
	def inspect(io : IO) : Nil
		self.class.to_s(io)
		io << '('
		to_s(io)
		io << ')'
	end

	# Appends the presentation representation of the block to the given `IO`.
	def to_s(io : IO) : Nil
		address.to_s(io)
		io << '/' << block
	end

	# :nodoc:
	class MalformedError < Exception
		def new()
			return new("The address was malformed.")
		end
	end
end

require "./block/*"
