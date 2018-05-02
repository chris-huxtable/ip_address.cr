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


private def address_should_eq(string : String, equals : String = string) : Nil
	IP::Address::IPv4[string].to_s.should eq(equals)
end

private def address_should_raise(string : String) : Nil
	expect_raises IP::Address::MalformedError do
		IP::Address::IPv4[string]
	end
end

private def address_should_eq?(string : String, equals : String = string) : Nil
	IP::Address::IPv4[string]?.to_s.should eq(equals)
end

private def address_should_be_nil(string : String) : Nil
	IP::Address::IPv4[string]?.should be_nil
end


describe IP::Address::IPv4 do

	describe ".[]" do
		it "takes strings" do
			address_should_eq("10.10.10.10")
			address_should_eq("10.10.0.1")
			address_should_eq("10.100.0.1")
			address_should_eq("127.0.0.0")
			address_should_eq("127.0.0.1")
			address_should_eq("0.0.0.0")
			address_should_eq("255.255.255.255")
		end

		it "shrinks unnecessarily long addresses" do
			address_should_eq("127.000.000.001", "127.0.0.1")
			address_should_eq("000.000.000.000", "0.0.0.0")
			address_should_eq("055.055.055.055", "55.55.55.55")
		end

		it "recognizes invalid addresses" do
			address_should_raise("")
			address_should_raise(" ")
			address_should_raise(".")
			address_should_raise("...")
			address_should_raise("0.0.0.")
			address_should_raise(".0.0.0")
			address_should_raise("0.0.0.0a")
			address_should_raise("a0.0.0.0")
			address_should_raise("0.a0.0.0")
			address_should_raise("0.0b.0.0")
			address_should_raise("a0.0.0.0a")
			address_should_raise("1.2.3.4.5")
			address_should_raise("1.2.3.4 5")
			address_should_raise("a.b.c.d")
			address_should_raise("*.*.*.*")
			address_should_raise("*.2.3.4")
			address_should_raise("1.*.3.4")
			address_should_raise("1.2.*.4")
			address_should_raise("1.2.3.*")
			address_should_raise("💩.💩.💩.💩")
			address_should_raise("💩.2.3.4")
			address_should_raise("1.💩.3.4")
			address_should_raise("1.2.💩.4")
			address_should_raise("1.2.3.💩")
			address_should_raise("256.255.255.255")
			address_should_raise("255.256.255.255")
			address_should_raise("255.255.256.255")
			address_should_raise("255.255.255.256")
			address_should_raise("10.10.10.10/10")
			address_should_raise("10.10.10.10 ")
			address_should_raise(" 10.10.10.10")
		end
	end

	describe ".[]?" do
		it "takes strings" do
			address_should_eq?("10.10.10.10")
			address_should_eq?("10.10.0.1")
			address_should_eq?("10.100.0.1")
			address_should_eq?("127.0.0.0")
			address_should_eq?("127.0.0.1")
			address_should_eq?("0.0.0.0")
			address_should_eq?("255.255.255.255")
		end

		it "shrinks unnecessarily long addresses" do
			address_should_eq?("127.000.000.001", "127.0.0.1")
			address_should_eq?("000.000.000.000", "0.0.0.0")
			address_should_eq?("055.055.055.055", "55.55.55.55")
		end

		it "recognizes invalid addresses" do
			address_should_be_nil("")
			address_should_be_nil(" ")
			address_should_be_nil(".")
			address_should_be_nil("...")
			address_should_be_nil("0.0.0.")
			address_should_be_nil(".0.0.0")
			address_should_be_nil("0.0.0.0a")
			address_should_be_nil("a0.0.0.0")
			address_should_be_nil("0.a0.0.0")
			address_should_be_nil("0.0b.0.0")
			address_should_be_nil("a0.0.0.0a")
			address_should_be_nil("1.2.3.4.5")
			address_should_be_nil("1.2.3.4 5")
			address_should_be_nil("a.b.c.d")
			address_should_be_nil("*.*.*.*")
			address_should_be_nil("*.2.3.4")
			address_should_be_nil("1.*.3.4")
			address_should_be_nil("1.2.*.4")
			address_should_be_nil("1.2.3.*")
			address_should_be_nil("💩.💩.💩.💩")
			address_should_be_nil("💩.2.3.4")
			address_should_be_nil("1.💩.3.4")
			address_should_be_nil("1.2.💩.4")
			address_should_be_nil("1.2.3.💩")
			address_should_be_nil("256.255.255.255")
			address_should_be_nil("255.256.255.255")
			address_should_be_nil("255.255.256.255")
			address_should_be_nil("255.255.255.256")
			address_should_be_nil("10.10.10.10/10")
			address_should_be_nil("10.10.10.10 ")
			address_should_be_nil(" 10.10.10.10")
		end
	end

	it "reports the correct type" do
		address = IP::Address::IPv4["192.168.1.1"]
		address.ipv4?.should be_true
		address.ipv6?.should_not be_true
	end

	it "supports addition" do
		addr = IP::Address::IPv4["10.10.0.1"]
		addr = addr + 1
		addr.to_s.should eq("10.10.0.2")

		addr = IP::Address::IPv4["10.10.0.255"]
		addr = addr + 1
		addr.to_s.should eq("10.10.1.0")

		addr = IP::Address::IPv4["10.10.0.2"]
		addr = addr + -1
		addr.to_s.should eq("10.10.0.1")
	end

	it "supports subtraction" do
		addr = IP::Address::IPv4["10.10.0.2"]
		addr = addr - 1
		addr.to_s.should eq("10.10.0.1")

		addr = IP::Address::IPv4["10.10.1.0"]
		addr = addr - 1
		addr.to_s.should eq("10.10.0.255")

		addr = IP::Address::IPv4["10.10.0.1"]
		addr = addr - -1
		addr.to_s.should eq("10.10.0.2")
	end

	it "supports address comparators" do
		addr0 = IP::Address::IPv4["10.10.0.1"]
		addr1 = IP::Address::IPv4["10.10.0.2"]

		(addr0 <=> addr1).should eq(-1)
		(addr1 <=> addr0).should eq(1)
		(addr0 <=> addr0).should eq(0)

		addr3 = IP::Address::IPv4["10.10.0.1"]

		(addr0 <=> addr3).should eq(0)
	end

	it "supports block comparators" do
		blk = IP::Block::IPv4["10.10.0.0/24"]

		addr0 = IP::Address::IPv4["10.10.0.1"]
		addr1 = IP::Address::IPv4["10.9.255.255"]
		addr2 = IP::Address::IPv4["10.11.0.0"]

		(addr0 <=> blk).should eq(0)
		(addr1 <=> blk).should eq(-1)
		(addr2 <=> blk).should eq(1)
	end

	it "supports equality" do
		addr = IP::Address::IPv4["10.10.0.1"]
		addr.should eq(addr)
		IP::Address::IPv4["10.10.0.1"].should eq(IP::Address::IPv4["10.10.0.1"])
		IP::Address::IPv4["10.10.0.1"].should_not eq(IP::Address::IPv4["10.10.0.0"])
	end

	it "supports adjacency" do
		addr0 = IP::Address::IPv4["10.10.0.1"]
		addr1 = IP::Address::IPv4["10.10.0.2"]
		addr0.adjacent?(addr1).should be_true
		addr1.adjacent?(addr0).should be_true

		addr0 = IP::Address::IPv4["10.10.0.255"]
		addr1 = IP::Address::IPv4["10.10.1.0"]
		addr0.adjacent?(addr1).should be_true
		addr1.adjacent?(addr0).should be_true

		addr0 = IP::Address::IPv4["0.0.0.0"]
		addr1 = IP::Address::IPv4["255.255.255.255"]
		addr0.adjacent?(addr1).should_not be_true
		addr1.adjacent?(addr0).should_not be_true
	end

	it "supports loopback?" do
		addr_true = IP::Address::IPv4["127.10.0.1"]
		addr_false = IP::Address::IPv4["10.10.0.1"]

		addr_true.loopback?.should be_true
		addr_false.loopback?.should_not be_true
	end

end
