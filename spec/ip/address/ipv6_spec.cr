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

private None = IP::Address::IPv6::Minification::None
private Simple = IP::Address::IPv6::Minification::Simple
private Agressive = IP::Address::IPv6::Minification::Agressive

private def address_should_eq(string : String, equals : String = string, file = __FILE__, line = __LINE__) : Nil
	IP::Address::IPv6[string].to_s.should eq(equals)
end

private def address_should_raise(string : String, file = __FILE__, line = __LINE__) : Nil
	expect_raises IP::Address::MalformedError do
		IP::Address::IPv6[string]
	end
end

private def address_should_eq?(string : String, equals : String = string, file = __FILE__, line = __LINE__) : Nil
	if ( addr = IP::Address::IPv6[string]? )
		addr.to_s(false, Agressive).should eq(equals)
	else
		fail("Address was nil", file, line)
	end
end

private def address_should_to_s?(string : String, equals : String = string, upcase : Bool = false, minify : IP::Address::IPv6::Minification = Simple, file = __FILE__, line = __LINE__) : Nil
	if ( addr = IP::Address::IPv6[string]? )
		addr.to_s(upcase, minify).should eq(equals)
	else
		fail("Address was nil", file, line)
	end
end

private def address_should_be_nil(string : String, file = __FILE__, line = __LINE__) : Nil
	IP::Address::IPv6[string]?.should be_nil
end


describe IP::Address::IPv6 do

	describe ".[]" do
		# TODO: Everything
	end

	describe ".[]?" do
		it "takes strings" do
			address_should_eq?("2001:0db8:0123:4567:89ab:cdef:1234:5678", "2001:db8:123:4567:89ab:cdef:1234:5678")
			address_should_eq?("2001:0db8:123:4567:89ab:cdef:1234:5678", "2001:db8:123:4567:89ab:cdef:1234:5678")
			address_should_eq?("0:0:0:0:0:0:0:0", "::0")
			address_should_eq?("1::2", "1::2")
			address_should_eq?("1::", "1::")
			address_should_eq?("::2", "::2")
			address_should_eq?("::9999", "::9999")
		end

		it "recognizes invalid addresses" do
			address_should_be_nil("")
			address_should_be_nil(" ")
			address_should_be_nil(".")
			address_should_be_nil("1.2.3.4")
			address_should_be_nil(":")
			address_should_be_nil("::")
			address_should_be_nil("0:0:0:0:0:0:0:0::")
			address_should_be_nil("::0:0:0:0:0:0:0:0")
			address_should_be_nil(":::")
			address_should_be_nil("ffff:eeee:dddd:cccc:bbbb:aaaa:1234:")
			address_should_be_nil(":eeee:dddd:cccc:bbbb:aaaa:1234:9999")
			address_should_be_nil("eeee:dddd:cccc:bbbb:aaaa:1234:9999")
			address_should_be_nil("gggg:eeee:dddd:cccc:bbbb:aaaa:1234:9999")
			address_should_be_nil("eeee:dddd:cccc:bbbb:aaaa:1234:9999:gggg")
			address_should_be_nil("eeee:****:cccc:bbbb:aaaa:1234:9999:1234")
			address_should_be_nil("eeeg:dddd:cccc:bbbb:aaaa:1234:9999:1234")
			address_should_be_nil("eeee:dddg:cccc:bbbb:aaaa:1234:9999:1234")
			address_should_be_nil("eeee:dddd:cccg:bbbb:aaaa:1234:9999:1234")
			address_should_be_nil("eeee:dddd:cccc:bbbg:aaaa:1234:9999:1234")
			address_should_be_nil("eeee:dddd:cccc:bbbb:aaag:1234:9999:1234")
			address_should_be_nil("eeee:dddd:cccc:bbbb:aaaa:123g:9999:1234")
			address_should_be_nil("eeee:dddd:cccc:bbbb:aaaa:1234:999g:1234")
			address_should_be_nil("eeee:dddd:cccc:bbbb:aaaa:1234:9999:123g")
			address_should_be_nil("💩:💩:💩:💩:💩:💩:💩:💩")
			address_should_be_nil("💩:b:c:d:e:f:1:2")
			address_should_be_nil("a:💩:c:d:e:f:1:2")
			address_should_be_nil("a:b:💩:d:e:f:1:2")
			address_should_be_nil("a:b:c:💩:e:f:1:2")
			address_should_be_nil("a:b:c:d:💩:f:1:2")
			address_should_be_nil("a:b:c:d:e:💩:1:2")
			address_should_be_nil("a:b:c:d:e:f:💩:2")
			address_should_be_nil("a:b:c:d:e:f:1:💩")
			address_should_be_nil("fffff:eeee:dddd:cccc:bbbb:aaaa:1234:9999")
			address_should_be_nil("ffff:eeeee:dddd:cccc:bbbb:aaaa:1234:9999")
			address_should_be_nil("ffff:eeee:ddddd:cccc:bbbb:aaaa:1234:9999")
			address_should_be_nil("ffff:eeee:dddd:ccccc:bbbb:aaaa:1234:9999")
			address_should_be_nil("ffff:eeee:dddd:cccc:bbbbb:aaaa:1234:9999")
			address_should_be_nil("ffff:eeee:dddd:cccc:bbbb:aaaaa:1234:9999")
			address_should_be_nil("ffff:eeee:dddd:cccc:bbbb:aaaa:12345:9999")
			address_should_be_nil("ffff:eeee:dddd:cccc:bbbb:aaaa:1234:99999")
			address_should_be_nil("ffff:eeee:dddd:cccc:bbbb:aaaa:1234:9999/128")
			address_should_be_nil("ffff:eeee:dddd:cccc:bbbb:aaaa:1234:9999 ")
			address_should_be_nil(" ffff:eeee:dddd:cccc:bbbb:aaaa:1234:9999")
		end
	end

	describe "stringification" do

		it "adjusts case" do
			address_should_to_s?("ffff:eeee:dddd:cccc:bbbb:aaaa:1234:9999")
			address_should_to_s?("ffff:eeee:dddd:cccc:bbbb:aaaa:1234:9999", "FFFF:EEEE:DDDD:CCCC:BBBB:AAAA:1234:9999", upcase: true, minify: None)
			address_should_to_s?("FFFF:EEEE:DDDD:CCCC:BBBB:AAAA:1234:9999", "FFFF:EEEE:DDDD:CCCC:BBBB:AAAA:1234:9999", upcase: true, minify: None)
			address_should_to_s?("FFFF:EEEE:DDDD:CCCC:BBBB:AAAA:1234:9999", "ffff:eeee:dddd:cccc:bbbb:aaaa:1234:9999", upcase: false, minify: None)
		end

		it "doesn't compress" do
			address_should_to_s?("ffff:eeee:dddd:cccc:bbbb:aaaa:1234:9999")
			address_should_to_s?("ffff:eeee:dddd:cccc:bbbb:aaaa:1234:9999", "FFFF:EEEE:DDDD:CCCC:BBBB:AAAA:1234:9999", upcase: true, minify: None)
			address_should_to_s?("FFFF:EEEE:DDDD:CCCC:BBBB:AAAA:1234:9999", "FFFF:EEEE:DDDD:CCCC:BBBB:AAAA:1234:9999", upcase: true, minify: None)
			address_should_to_s?("FFFF:EEEE:DDDD:CCCC:BBBB:AAAA:1234:9999", "ffff:eeee:dddd:cccc:bbbb:aaaa:1234:9999", upcase: false, minify: None)

			address_should_to_s?("0:0:0:0:0:0:0:0", "0000:0000:0000:0000:0000:0000:0000:0000", upcase: false, minify: None)
		end

		it "simply compresses" do
			address_should_to_s?("FFFF:EEEE:0000:0000:0000:AAAA:1234:9999", "ffff:eeee::aaaa:1234:9999", minify: Simple)
			address_should_to_s?("FFFF:EEEE:0000:0000:0000:AAAA:0012:9999", "ffff:eeee::aaaa:12:9999", minify: Simple)
			address_should_to_s?("0000:EEEE:0000:0000:0000:AAAA:1234:9999", "::eeee:0:0:0:aaaa:1234:9999", minify: Simple)
			address_should_to_s?("FFFF:EEEE:0000:0000:0000:AAAA:0012:0000", "ffff:eeee::aaaa:12:0", minify: Simple)

			address_should_to_s?("0000:0000:0000:0000:0000:0000:0000:0001", "::1", minify: Simple)
			address_should_to_s?("0001:0000:0000:0000:0000:0000:0000:0000", "1::", minify: Simple)
			address_should_to_s?("0000:0000:0000:0000:0000:0000:0001:0000", "::1:0", minify: Simple)
			address_should_to_s?("0000:0001:0000:0000:0000:0000:0000:0000", "::1:0:0:0:0:0:0", minify: Simple)

			address_should_to_s?("0:0:0:0:0:0:0:0", "::0", minify: Simple)
		end

		it "aggressively compresses" do
			address_should_to_s?("FFFF:EEEE:0000:0000:0000:AAAA:1234:9999", "ffff:eeee::aaaa:1234:9999", minify: Agressive)
			address_should_to_s?("FFFF:EEEE:0000:0000:0000:AAAA:0012:9999", "ffff:eeee::aaaa:12:9999", minify: Agressive)
			address_should_to_s?("0000:EEEE:0000:0000:0000:AAAA:1234:9999", "0:eeee::aaaa:1234:9999", minify: Agressive)
			address_should_to_s?("FFFF:EEEE:0000:0000:0000:AAAA:0012:0000", "ffff:eeee::aaaa:12:0", minify: Agressive)

			address_should_to_s?("0000:0000:0000:0000:0000:0000:0000:0001", "::1", minify: Agressive)
			address_should_to_s?("0001:0000:0000:0000:0000:0000:0000:0000", "1::", minify: Agressive)
			address_should_to_s?("0000:0000:0000:0000:0000:0000:0001:0000", "::1:0", minify: Agressive)
			address_should_to_s?("0000:0001:0000:0000:0000:0000:0000:0000", "0:1::", minify: Agressive)

			address_should_to_s?("0:0:0:0:0:0:0:0", "::0", minify: Agressive)
		end

	end


end
