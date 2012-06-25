require 'estem'

hsh = Hash.new

words = ['albergues','habitaciones','Albergues','ALbeRGues','HaBiTaCiOnEs',
         'Hacinamiento','mujeres','muchedumbre','ocasionalmente']

words.each do|w|
	stem = w.es_stem
	puts "Word: #{w}\nStem: #{stem}\n\n"
end
