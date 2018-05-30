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

require "./ip/address"
require "./ip/block"

module IP

	# Constructs a new IPv4 or IPv6 `IP::Address` or `IP::Block` by interpreting the contents of a `String`.
	#
	# Expects an address in acceptable form.
	#
	# Raises: `MalformedError` when the input is malformed.
	def self.[](string : String)
		addr = new?(string)
		raise MalformedError.new() if ( !addr )
		return addr
	end

	# ditto
	def self.new(string : String)
		addr = new?(string)
		raise MalformedError.new() if ( !addr )
		return addr
	end

	# Constructs a new IPv4 or IPv6 `IP::Address` by interpreting  the contents of a `String`.
	#
	# Expects an address in acceptable form.
	#
	# Returns `nil` when the input is malformed.
	def self.[]?(string : String)
		return new?(string)
	end

	# ditto
	def self.new?(string : String)
		return nil if ( string.empty?() )

		if ( string.count('/') < 1 )
			return Address::IPv4.new?(string) if ( string.count('.') == 3 )
			return Address::IPv6.new?(string) if ( string.count(':') > 1 )
		else
			return Block::IPv4.new?(string) if ( string.count('.') == 3 )
			return Block::IPv6.new?(string) if ( string.count(':') > 1 )
		end

		return nil
	end

	# :nodoc:
	class MalformedError < Exception
		def new()
			return new("The address was malformed.")
		end
	end

end
