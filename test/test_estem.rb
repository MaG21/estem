# encoding: UTF-8

require 'test/unit'
require 'estem'

class EStemTest < Test::Unit::TestCase
	def get_content(filename)
		content = nil
		File.open(filename, 'r:UTF-8') do |f|
			content = f.read()
		end
		content.scan(/(\S+)(?:\s+)(\S+)/)
	end

	def test_stem
		# assuming we will run the test from the root directory of the project
		# using "rake test" from the command-line
		for word, good in get_content('test/diffs.txt')
			assert_equal(good, word.es_stem, "input: " + word)
		end  
	end
  
end
