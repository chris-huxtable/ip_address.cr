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
		IP::Block::IPv4[string].to_s.should(eq(equals), file, line)
	rescue ex
		fail("#{equals} #{ex.message}", file, line)
	end
end

private def should_eq?(string : String, equals : String = string, file = __FILE__, line = __LINE__) : Nil
	if ( addr = IP::Block::IPv4[string]? )
		addr.to_s().should(eq(equals), file, line)
	else
		fail("Address was nil", file, line)
	end
end

private def should_raise(string : String, file = __FILE__, line = __LINE__) : Nil
	expect_raises(IP::MalformedError, nil, file, line) { IP::Block::IPv4[string] }
end

private def should_be_nil(string : String, file = __FILE__, line = __LINE__) : Nil
	IP::Block::IPv4[string]?.should(be_nil, file, line)
end


private def should_cover(blk0 : String, blk1 : String) : Nil
	IP::Block::IPv4[blk0].covers?(IP::Block::IPv4[blk1]).should be_true
end

private def should_not_cover(blk0 : String, blk1 : String) : Nil
	IP::Block::IPv4[blk0].covers?(IP::Block::IPv4[blk1]).should_not be_true
end

private def should_cover_addr(blk : String, addr : String) : Nil
	IP::Block::IPv4[blk].covers?(IP::Address::IPv4[addr]).should be_true
end

private def should_not_cover_addr(blk : String, addr : String) : Nil
	IP::Block::IPv4[blk].covers?(IP::Address::IPv4[addr]).should_not be_true
end


private def should_intersect(blk0 : String, blk1 : String) : Nil
	IP::Block::IPv4[blk0].intersects?(IP::Block::IPv4[blk1]).should be_true
end

private def should_not_intersect(blk0 : String, blk1 : String) : Nil
	IP::Block::IPv4[blk0].intersects?(IP::Block::IPv4[blk1]).should_not be_true
end

private def should_intersect_addr(blk : String, addr : String) : Nil
	IP::Block::IPv4[blk].intersects?(IP::Address::IPv4[addr]).should be_true
end

private def should_not_intersect_addr(blk : String, addr : String) : Nil
	IP::Block::IPv4[blk].intersects?(IP::Address::IPv4[addr]).should_not be_true
end


private def should_be_adjacent(blk0 : String, blk1 : String) : Nil
	IP::Block::IPv4[blk0].adjacent?(IP::Block::IPv4[blk1]).should be_true
end

private def should_not_be_adjacent(blk0 : String, blk1 : String) : Nil
	IP::Block::IPv4[blk0].adjacent?(IP::Block::IPv4[blk1]).should_not be_true
end

private def should_be_adjacent_addr(blk : String, addr : String) : Nil
	IP::Block::IPv4[blk].adjacent?(IP::Address::IPv4[addr]).should be_true
end

private def should_not_be_adjacent_addr(blk : String, addr : String) : Nil
	IP::Block::IPv4[blk].adjacent?(IP::Address::IPv4[addr]).should_not be_true
end


private def should_be_lt(blk0 : String, blk1 : String, value : Bool = true) : Nil
	(IP::Block::IPv4[blk0] < IP::Block::IPv4[blk1]).should eq(value)
end

private def should_be_gt(blk0 : String, blk1 : String, value : Bool = true) : Nil
	(IP::Block::IPv4[blk0] > IP::Block::IPv4[blk1]).should eq(value)
end

private def should_be_lte(blk0 : String, blk1 : String, value : Bool = true) : Nil
	(IP::Block::IPv4[blk0] <= IP::Block::IPv4[blk1]).should eq(value)
end

private def should_be_gte(blk0 : String, blk1 : String, value : Bool = true) : Nil
	(IP::Block::IPv4[blk0] >= IP::Block::IPv4[blk1]).should eq(value)
end


private def should_be_lt_addr(blk : String, addr : String, value : Bool = true) : Nil
	(IP::Block::IPv4[blk] < IP::Address::IPv4[addr]).should eq(value)
end

private def should_be_gt_addr(blk : String, addr : String, value : Bool = true) : Nil
	(IP::Block::IPv4[blk] > IP::Address::IPv4[addr]).should eq(value)
end

private def should_be_lte_addr(blk : String, addr : String, value : Bool = true) : Nil
	(IP::Block::IPv4[blk] <= IP::Address::IPv4[addr]).should eq(value)
end

private def should_be_gte_addr(blk : String, addr : String, value : Bool = true) : Nil
	(IP::Block::IPv4[blk] >= IP::Address::IPv4[addr]).should eq(value)
end


private def should_produce_mask(blk : String, addr : String) : Nil
	IP::Block::IPv4[blk].mask.to_s.should eq(addr)
end


private def should_have_properties(blk : String, block : Int, size : Int, first : String, last : String) : Nil
	blk = IP::Block::IPv4[blk]
	blk.block().should eq(block.to_u8)
	blk.size().should eq(size.to_u32)

	blk.first.to_s.should eq(first)
	blk.last.to_s.should eq(last)
end


describe IP::Block::IPv4 do

	describe ".[]" do
		it "takes strings" do
			should_eq("10.0.0.0/24")
			should_eq("10.10.0.0/20")
			should_eq("10.100.0.0/2")
			should_eq("0.0.0.0/0")
			should_eq("0.0.0.0/16")

			[0, 128, 192, 224, 240, 248, 252, 254, 255].each_with_index() { |number, index|
				should_eq("#{number}.0.0.0/#{index}")
				should_eq("255.#{number}.0.0/#{index + 8}")
				should_eq("255.255.#{number}.0/#{index + 16}")
				should_eq("255.255.255.#{number}/#{index + 24}")
			}
		end

		it "shrinks unnecessarily long blocks" do
			should_eq("127.000.000.001/08", "127.0.0.1/8")
			should_eq("000.000.000.000/00", "0.0.0.0/0")
			should_eq("055.055.055.055/024", "55.55.55.55/24")
		end

		it "recognizes invalid blocks" do
			should_raise("")
			should_raise(" ")
			should_raise("/")
			should_raise(".")
			should_raise(".../")
			should_raise("/32")
			should_raise("0.0.0.")
			should_raise(".0.0.0")
			should_raise("1.2.3.4")
			should_raise("1.2.3.4/💩")
			should_raise("1.2.3.💩/4")

			[0, 128, 192, 224, 240, 248, 252, 254, 255].each_with_index() { |number, index|
				should_raise("#{number}.0.0.1/#{index}")
				should_raise("255.#{number}.0.1/#{index + 8}")
				should_raise("255.255.#{number}.1/#{index + 16}")
				should_raise("255.255.255.#{number + 1}/#{index + 24}")
			}
		end
	end

	describe ".[]?" do
		it "takes strings" do
			should_eq?("10.0.0.0/24")
			should_eq?("10.10.0.0/20")
			should_eq?("10.100.0.0/2")
			should_eq?("0.0.0.0/0")

			[0, 128, 192, 224, 240, 248, 252, 254, 255].each_with_index() { |number, index|
				should_eq?("#{number}.0.0.0/#{index}")
				should_eq?("255.#{number}.0.0/#{index + 8}")
				should_eq?("255.255.#{number}.0/#{index + 16}")
				should_eq?("255.255.255.#{number}/#{index + 24}")
			}
		end

		it "shrinks unnecessarily long blocks" do
			should_eq?("127.000.000.001/08", "127.0.0.1/8")
			should_eq?("000.000.000.000/00", "0.0.0.0/0")
			should_eq?("055.055.055.055/024", "55.55.55.55/24")
		end

		it "recognizes invalid block" do
			should_be_nil("")
			should_be_nil(" ")
			should_be_nil("/")
			should_be_nil(".")
			should_be_nil(".../")
			should_be_nil("/32")
			should_be_nil("0.0.0.")
			should_be_nil(".0.0.0")
			should_be_nil("1.2.3.4")
			should_be_nil("1.2.3.4/💩")
			should_be_nil("1.2.3.💩/4")

			[0, 128, 192, 224, 240, 248, 252, 254, 255].each_with_index() { |number, index|
				should_be_nil("#{number}.0.0.1/#{index}")
				should_be_nil("255.#{number}.0.1/#{index + 8}")
				should_be_nil("255.255.#{number}.1/#{index + 16}")
				should_be_nil("255.255.255.#{number + 1}/#{index + 24}")
			}
		end
	end

	it "reports the correct type" do
		block = IP::Block::IPv4["192.168.1.1/21"]
		block.ipv4?.should be_true
		block.ipv6?.should_not be_true
	end

	it "supports covers? with block" do
		should_cover("10.0.0.0/8", "10.0.0.0/24")     # Subset Front
		should_cover("10.0.0.0/8", "10.0.10.0/24")    # Subset Middle
		should_cover("10.0.0.0/8", "10.255.255.0/24") # Subset Rear
		should_cover("10.0.0.0/8", "10.0.0.0/8")      # Full Overlap

		should_not_cover("10.0.0.0/24", "10.0.0.0/8")  # Partial Middle
		should_not_cover("10.0.0.0/8", "9.192.0.0/8")  # Partial Front
		should_not_cover("10.0.0.0/8", "10.192.0.0/8") # Partial Rear
		should_not_cover("10.0.0.0/8", "11.0.0.0/24")  # No Overlap
	end

	it "supports covers? with address" do
		should_cover_addr("10.0.0.0/8", "10.0.0.0")       # Front
		should_cover_addr("10.0.0.0/8", "10.0.10.0")      # Middle
		should_cover_addr("10.0.0.0/8", "10.255.255.255") # Rear

		should_not_cover_addr("10.0.0.0/8", "9.255.255.255") # Just Before
		should_not_cover_addr("10.0.0.0/8", "11.0.0.0")      # Just After
		should_not_cover_addr("10.0.0.0/8", "234.0.0.0")     # Middle of Nowhere
	end

	it "supports intersects? with block" do
		should_intersect("10.0.0.0/24", "10.0.0.0/8")  # Partial Middle
		should_intersect("10.0.0.0/8", "10.0.0.0/24")  # Partial Over
		should_intersect("10.0.0.0/8", "9.192.0.0/8")  # Partial Front
		should_intersect("10.0.0.0/8", "10.192.0.0/8") # Partial Rear

		should_not_intersect("10.0.0.0/8", "11.0.0.0/24") # No Overlap
	end

	it "supports intersects? with address" do
		should_intersect_addr("10.0.0.0/8", "10.0.0.0")       # Front
		should_intersect_addr("10.0.0.0/8", "10.128.0.0")     # Middle
		should_intersect_addr("10.0.0.0/8", "10.255.255.255") # Rear

		should_not_intersect_addr("10.0.0.0/8", "9.255.255.255") # Just Before
		should_not_intersect_addr("10.0.0.0/8", "11.0.0.0")      # Rear
		should_not_intersect_addr("10.0.0.0/8", "127.0.0.0")     # Middle of Nowhere
	end

	it "supports adjacent? with block" do
		should_be_adjacent("10.0.0.0/8", "11.0.0.0/24") # Rear
		should_be_adjacent("10.0.0.0/8", "9.0.0.0/8")   # Front

		should_be_adjacent("10.0.0.1/32", "10.0.0.2/32") # Single-Single (Front)
		should_be_adjacent("10.0.0.0/32", "9.0.0.0/8")   # Single-Multi (Front)
		should_be_adjacent("9.0.0.0/8", "10.0.0.0/32")   # Multi-Single (Front)

		should_be_adjacent("10.0.0.2/32", "10.0.0.1/32")      # Single-Single (Rear)
		should_be_adjacent("9.255.255.255/32", "10.0.0.0/24") # Single-Multi (Rear)
		should_be_adjacent("10.0.0.0/24", "9.255.255.255/32") # Multi-Single (Rear)

		should_be_adjacent("10.0.1.0/24", "10.0.0.0/24") # Just Before
		should_be_adjacent("10.0.1.0/24", "10.0.2.0/24") # Just Past

		should_not_be_adjacent("10.0.0.0/8", "10.192.0.0/24")   # Inner Middle
		should_not_be_adjacent("10.0.0.0/8", "10.0.0.0/24")     # Inner Front
		should_not_be_adjacent("10.0.0.0/8", "10.255.255.0/24") # Inner Rear
		should_not_be_adjacent("10.0.0.0/8", "9.255.254.0/24")  # Distant Front
		should_not_be_adjacent("10.0.0.0/8", "11.0.0.1/31")     # Distant Rear

		should_not_be_adjacent("10.0.1.0/24", "10.0.0.127/25") # Just, Just Before
		should_not_be_adjacent("10.0.1.0/24", "10.0.2.1/24")   # Just, Just Past
	end

	it "supports adjacent? with address" do
		should_be_adjacent_addr("10.0.0.0/24", "9.255.255.255") # Just Before
		should_be_adjacent_addr("10.0.0.0/24", "10.0.1.0")      # Just Past

		should_not_be_adjacent_addr("10.0.0.0/24", "9.255.255.254") # Just Just Before
		should_not_be_adjacent_addr("10.0.0.0/24", "10.0.1.1")      # Just Just Past
		should_not_be_adjacent_addr("10.0.0.0/24", "11.0.0.0")      # Middle of Nowhere
	end

	it "supports < and > with block" do
		should_be_lt("10.0.1.0/24", "10.0.2.0/24")   # Just Past
		should_be_lt("10.0.1.0/24", "10.0.2.1/25")   # Just Just Past
		should_be_lt("10.0.1.0/24", "127.0.34.0/24") # Distant Past

		should_be_gt("10.0.1.0/24", "10.0.0.0/24")   # Just Before
		should_be_gt("10.0.1.0/24", "10.0.0.127/25") # Just Just Before
		should_be_gt("10.0.1.0/24", "1.0.34.0/24")   # Distant Before
	end

	it "supports <= and >= with block" do
		should_be_gte("10.0.0.0/8", "9.192.0.0/8")         # Partial Front
		should_be_gte("10.0.0.0/8", "10.0.0.0/24")         # Front
		should_be_gte("10.0.0.0/8", "10.0.0.0/24")         # Middle
		should_be_gte("10.0.0.0/8", "10.255.255.0/24")     # Rear
		should_be_gte("10.0.0.0/8", "10.192.0.0/8", false) # Partial Rear

		should_be_lte("10.0.0.0/8", "10.192.0.0/8")       # Partial Rear
		should_be_lte("10.0.0.0/8", "10.0.0.0/24")        # Front
		should_be_lte("10.0.0.0/8", "10.0.0.0/24")        # Middle
		should_be_lte("10.0.0.0/8", "10.255.255.0/24")    # Rear
		should_be_lte("10.0.0.0/8", "9.192.0.0/8", false) # Partial Front
	end

	it "supports < and > with address" do
		should_be_lt_addr("10.0.1.0/24", "10.0.2.0")   # Just Past
		should_be_lt_addr("10.0.1.0/24", "10.0.2.1")   # Just Just Past

		should_be_gt_addr("10.0.1.0/24", "10.0.0.255") # Just Before
		should_be_gt_addr("10.0.1.0/24", "10.0.0.254") # Just Just Before
	end

	it "supports <= and >= with address" do
		should_be_lte_addr("10.0.0.0/24", "128.0.0.0")        # Past
		should_be_lte_addr("10.0.0.0/24", "11.0.0.0")         # Just Past
		should_be_lte_addr("10.0.0.0/24", "10.0.0.0")         # Front
		should_be_lte_addr("10.0.0.0/24", "10.0.0.127")       # Middle
		should_be_lte_addr("10.0.0.0/24", "10.0.0.255")       # End
		should_be_lte_addr("10.0.0.0/24", "5.192.0.0", false) # Before Fail

		should_be_gte_addr("10.0.0.0/24", "1.0.0.0")           # Before
		should_be_gte_addr("10.0.0.0/24", "9.255.255.255")     # Just Before
		should_be_gte_addr("10.0.0.0/24", "10.0.0.0")          # Front
		should_be_gte_addr("10.0.0.0/24", "10.0.0.127")        # Middle
		should_be_gte_addr("10.0.0.0/24", "10.0.0.255")        # End
		should_be_gte_addr("10.0.0.0/24", "10.192.0.0", false) # Past Fail
	end

	it "supports <=> with addresses" do
		blk = IP::Block::IPv4["10.10.0.0/24"]

		addr0 = IP::Address::IPv4["10.10.0.1"]
		addr1 = IP::Address::IPv4["10.9.255.255"]
		addr2 = IP::Address::IPv4["10.11.0.0"]

		(blk <=> addr0).should eq(0)
		(blk <=> addr1).should eq(1)
		(blk <=> addr2).should eq(-1)
	end

	it "supports mask" do
		should_produce_mask("10.0.0.0/32", "255.255.255.255")
		should_produce_mask("10.0.0.0/31", "255.255.255.254")
		should_produce_mask("10.0.0.0/30", "255.255.255.252")
		should_produce_mask("10.0.0.0/29", "255.255.255.248")
		should_produce_mask("10.0.0.0/28", "255.255.255.240")
		should_produce_mask("10.0.0.0/27", "255.255.255.224")
		should_produce_mask("10.0.0.0/26", "255.255.255.192")
		should_produce_mask("10.0.0.0/25", "255.255.255.128")
		should_produce_mask("10.0.0.0/24", "255.255.255.0")
		should_produce_mask("10.0.0.0/23", "255.255.254.0")
		should_produce_mask("10.0.0.0/22", "255.255.252.0")
		should_produce_mask("10.0.0.0/21", "255.255.248.0")
		should_produce_mask("10.0.0.0/20", "255.255.240.0")
		should_produce_mask("10.0.0.0/19", "255.255.224.0")
		should_produce_mask("10.0.0.0/18", "255.255.192.0")
		should_produce_mask("10.0.0.0/17", "255.255.128.0")
		should_produce_mask("10.0.0.0/16", "255.255.0.0")
		should_produce_mask("10.0.0.0/15", "255.254.0.0")
		should_produce_mask("10.0.0.0/14", "255.252.0.0")
		should_produce_mask("10.0.0.0/13", "255.248.0.0")
		should_produce_mask("10.0.0.0/12", "255.240.0.0")
		should_produce_mask("10.0.0.0/11", "255.224.0.0")
		should_produce_mask("10.0.0.0/10", "255.192.0.0")
		should_produce_mask("10.0.0.0/9", "255.128.0.0")
		should_produce_mask("10.0.0.0/8", "255.0.0.0")
		should_produce_mask("10.0.0.0/7", "254.0.0.0")
		should_produce_mask("10.0.0.0/6", "252.0.0.0")
		should_produce_mask("10.0.0.0/5", "248.0.0.0")
		should_produce_mask("10.0.0.0/4", "240.0.0.0")
		should_produce_mask("10.0.0.0/3", "224.0.0.0")
		should_produce_mask("10.0.0.0/2", "192.0.0.0")
		should_produce_mask("10.0.0.0/1", "128.0.0.0")
		should_produce_mask("0.0.0.0/0", "0.0.0.0")
	end

	it "supports properties" do
		should_have_properties("10.0.0.0/32", 32,  1, "10.0.0.0", "10.0.0.0")
		should_have_properties("10.0.0.0/31", 31,  2, "10.0.0.0", "10.0.0.1")
		should_have_properties("10.0.0.0/30", 30,  4, "10.0.0.0", "10.0.0.3")
		should_have_properties("10.0.0.0/29", 29,  8, "10.0.0.0", "10.0.0.7")
		should_have_properties("10.0.0.0/28", 28, 16, "10.0.0.0", "10.0.0.15")
		should_have_properties("10.0.0.0/27", 27, 32, "10.0.0.0", "10.0.0.31")
		should_have_properties("10.0.0.0/26", 26, 64, "10.0.0.0", "10.0.0.63")
		should_have_properties("10.0.0.0/25", 25, 128, "10.0.0.0", "10.0.0.127")
		should_have_properties("10.0.0.0/24", 24, 256, "10.0.0.0", "10.0.0.255")
		should_have_properties("10.0.0.0/23", 23, 512, "10.0.0.0", "10.0.1.255")
		should_have_properties("10.0.0.0/22", 22, 1_024, "10.0.0.0", "10.0.3.255")
		should_have_properties("10.0.0.0/21", 21, 2_048, "10.0.0.0", "10.0.7.255")
		should_have_properties("10.0.0.0/20", 20, 4_096, "10.0.0.0", "10.0.15.255")
		should_have_properties("10.0.0.0/19", 19, 8_192, "10.0.0.0", "10.0.31.255")
		should_have_properties("10.0.0.0/18", 18, 16_384, "10.0.0.0", "10.0.63.255")
		should_have_properties("10.0.0.0/17", 17, 32_768, "10.0.0.0", "10.0.127.255")
		should_have_properties("10.0.0.0/16", 16, 65_536, "10.0.0.0", "10.0.255.255")
		should_have_properties("10.0.0.0/15", 15, 131_072, "10.0.0.0", "10.1.255.255")
		should_have_properties("10.0.0.0/14", 14, 262_144, "10.0.0.0", "10.3.255.255")
		should_have_properties("10.0.0.0/13", 13, 524_288, "10.0.0.0", "10.7.255.255")
		should_have_properties("10.0.0.0/12", 12, 1_048_576, "10.0.0.0", "10.15.255.255")
		should_have_properties("10.0.0.0/11", 11, 2_097_152, "10.0.0.0", "10.31.255.255")
		should_have_properties("10.0.0.0/10", 10, 4_194_304, "10.0.0.0", "10.63.255.255")
		should_have_properties("10.0.0.0/9", 9, 8_388_608, "10.0.0.0", "10.127.255.255")
		should_have_properties("10.0.0.0/8", 8, 16_777_216, "10.0.0.0", "10.255.255.255")
		should_have_properties("10.0.0.0/7", 7, 33_554_432, "10.0.0.0", "11.255.255.255")
		should_have_properties("10.0.0.0/6", 6, 67_108_864, "10.0.0.0", "13.255.255.255")
		should_have_properties("10.0.0.0/5", 5, 134_217_728, "10.0.0.0", "17.255.255.255")
		should_have_properties("10.0.0.0/4", 4, 268_435_456, "10.0.0.0", "25.255.255.255")
		should_have_properties("10.0.0.0/3", 3, 536_870_912, "10.0.0.0", "41.255.255.255")
		should_have_properties("10.0.0.0/2", 2, 1_073_741_824, "10.0.0.0", "73.255.255.255")
		should_have_properties("10.0.0.0/1", 1, 2_147_483_648, "10.0.0.0", "137.255.255.255")
		should_have_properties("0.0.0.0/0", 0, 4_294_967_296, "0.0.0.0", "255.255.255.255")
	end

	it "supports loopback" do
		loopback = IP::Block.loopback_ipv4()
		should_have_properties(loopback.to_s, 8, 16_777_216, "127.0.0.0", "127.255.255.255")
	end

end
