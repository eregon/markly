# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Benoit Daloze.

require "markly"

describe Markly::Node do
	def garbage_collect
		3.times {GC.start}
	end

	def emphasis_of_new_document
		document = Markly.parse("Hello *world*!")
		paragraph = document.first_child
		paragraph.first_child.next
	end

	with "lifetime" do
		it "keeps the tree alive while only a descendant node is referenced" do
			emphasis = emphasis_of_new_document
			garbage_collect

			expect(emphasis.type).to be == :emph
			expect(emphasis.first_child.string_content).to be == "world"
			expect(emphasis.parent.type).to be == :paragraph
			expect(emphasis.parent.parent.type).to be == :document
		end

		it "frees trees with cached child nodes" do
			100.times do
				document = Markly.parse("# Title\n\nSome *emphasis* with [a link](http://example.com) and `code`.\n\n- one\n- two\n")
				document.walk {|node| node.type}
			end

			garbage_collect

			document = Markly.parse("Still *working*")
			expect(document.to_html).to be == "<p>Still <em>working</em></p>\n"
		end
	end
end
