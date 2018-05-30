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

private def should_eq(string : String, equals : String = string, file = __FILE__, line = __LINE__) : Nil
	begin
		IP::Block::IPv6[string].to_s.should(eq(equals), file, line)
	rescue ex
		fail("#{equals} #{ex.message}", file, line)
	end
end

private def should_eq?(string : String, equals : String = string, file = __FILE__, line = __LINE__) : Nil
	if ( addr = IP::Block::IPv6[string]? )
		addr.to_s().should(eq(equals), file, line)
	else
		fail("Address was nil", file, line)
	end
end

private def should_raise(string : String, file = __FILE__, line = __LINE__) : Nil
	expect_raises(IP::MalformedError, nil, file, line) { IP::Block::IPv6[string] }
end

private def should_be_nil(string : String, file = __FILE__, line = __LINE__) : Nil
	IP::Block::IPv6[string]?.should(be_nil, file, line)
end


describe IP::Block::IPv6 do

	describe ".[]" do
		should_eq("2001:0db8:0123:4567:89ab:cdef:1234:5678/96", "2001:db8:123:4567:89ab:cdef:1234:5678/96")
		should_eq("2001:db8:123:4567:89ab:cdef:1234:5678/96")
		should_eq("0:0:0:0:0:0:0:0/32", "::0/32")
		should_eq("1::2/24", "1::2/24")
		should_eq("1::/96", "1::/96")
		should_eq("::2/96", "::2/96")
		should_eq("::9999/96", "::9999/96")
		should_eq("::/128", "::0/128")
	end

	describe ".[]?" do
		should_eq?("2001:0db8:0123:4567:89ab:cdef:1234:5678/96", "2001:db8:123:4567:89ab:cdef:1234:5678/96")
		should_eq?("2001:db8:123:4567:89ab:cdef:1234:5678/96")
		should_eq?("0:0:0:0:0:0:0:0/32", "::0/32")
		should_eq?("1::2/24", "1::2/24")
		should_eq?("1::/96", "1::/96")
		should_eq?("::2/96", "::2/96")
		should_eq?("::9999/96", "::9999/96")
		should_eq?("::/128", "::0/128")
	end

end
