require 'test/unit'
require 'estem'

# NOTE:
# assuming we will run the test from the root directory of the project
# using "rake test" from the command-line

class EStemTest < Test::Unit::TestCase
	def get_content(filename, encoding='UTF-8')
		content = nil
		File.open(filename, "r:#{encoding}") do |f|
			content = f.read()
		end
		content.scan(/(\S+)(?:\s+)(\S+)/)
	end

	def test_estem
		for word, good in get_content('test/diffs_UTF8.txt')
			assert_equal(good, word.es_stem, "input: " + word)
		end

		for word, good in get_content('test/diffs_ISO88591.txt', 'ISO-8859-1')
			ret = word.safe_es_stem
			assert_equal(good, ret, "input: " + word)
			assert_equal('ISO-8859-1', ret.encoding.name.upcase)
		end
	end
end
