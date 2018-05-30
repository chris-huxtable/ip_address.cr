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

require "./spec_helper"
require "./ip/*"
require "../src/ip_address"


private def should_eq(string : String, equals : String = string, file = __FILE__, line = __LINE__) : Nil
	begin
		IP[string].to_s.should(eq(equals), file, line)
	rescue ex
		fail("#{equals} #{ex.message}", file, line)
	end
end

private def should_eq?(string : String, equals : String = string, file = __FILE__, line = __LINE__) : Nil
	if ( addr = IP[string]? )
		addr.to_s().should(eq(equals), file, line)
	else
		fail("Address was nil", file, line)
	end
end

private def should_raise(string : String, file = __FILE__, line = __LINE__) : Nil
	expect_raises(IP::MalformedError, nil, file, line) { IP[string] }
end

private def should_be_nil(string : String, file = __FILE__, line = __LINE__) : Nil
	IP[string]?.should(be_nil, file, line)
end


describe IP do

	it "takes strings" do
		should_eq("10.10.10.10")
		should_eq?("10.10.10.10")
		should_eq("10.10.10.10/24")
		should_eq?("10.10.10.10/24")

		should_eq("2001:db8:123:4567:89ab:cdef:1234:5678")
		should_eq?("2001:db8:123:4567:89ab:cdef:1234:5678")
		should_eq("2001:db8:123:4567:89ab:cdef:1234:5678/96")
		should_eq?("2001:db8:123:4567:89ab:cdef:1234:5678/96")
	end

	it "shrinks unnecessarily long addresses" do
		should_eq("127.000.000.001", "127.0.0.1")
		should_eq?("127.000.000.001", "127.0.0.1")
		should_eq("127.000.000.001/24", "127.0.0.1/24")
		should_eq?("127.000.000.001/24", "127.0.0.1/24")

		should_eq("FFFF:EEEE:0000:0000:0000:AAAA:1234:9999", "ffff:eeee::aaaa:1234:9999")
		should_eq?("FFFF:EEEE:0000:0000:0000:AAAA:1234:9999", "ffff:eeee::aaaa:1234:9999")
		should_eq("FFFF:EEEE:0000:0000:0000:AAAA:1234:9999/96", "ffff:eeee::aaaa:1234:9999/96")
		should_eq?("FFFF:EEEE:0000:0000:0000:AAAA:1234:9999/96", "ffff:eeee::aaaa:1234:9999/96")
	end

	it "recognizes invalid addresses" do
		should_raise("10.0.0.")
		should_raise("1.2.3.4.5")
		should_raise("1.2.3.4/")
		should_raise("1.2.3.4/33")
		should_raise("1.2.3.4/32 ")

		should_raise("2001:db8:123:4567:89ab:cdef:1234:")
		should_raise("2001:db8:123:4567:89ab:cdef:1234:5678:9999")
		should_raise("2001:db8:123:4567:89ab:cdef:1234:5678/")
		should_raise("2001:db8:123:4567:89ab:cdef:1234:5678/129")
		should_raise("2001:db8:123:4567:89ab:cdef:1234:5678/128 ")

		should_be_nil("0.0.0.")
		should_be_nil("1.2.3.4.5")
		should_be_nil("1.2.3.4/")
		should_be_nil("1.2.3.4/33")
		should_be_nil("1.2.3.4/33 ")

		should_be_nil("2001:db8:123:4567:89ab:cdef:1234:")
		should_be_nil("2001:db8:123:4567:89ab:cdef:1234:5678:9999")
		should_be_nil("2001:db8:123:4567:89ab:cdef:1234:5678/")
		should_be_nil("2001:db8:123:4567:89ab:cdef:1234:5678/129")
		should_be_nil("2001:db8:123:4567:89ab:cdef:1234:5678/128 ")
	end

end
