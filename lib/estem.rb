# encoding: UTF-8
#
# :title: Spanish Stemming
# = Description
# This gem is for reducing Spanish words to their roots. It uses an algorithm
# based on Martin Porter's specifications.
#  
# For more information, visit:
# http://snowball.tartarus.org/algorithms/spanish/stemmer.html
# 
# = Descripción
# Esta gema está para reducir las palabras del Español en sus respectivas raíces,
# para ello ultiliza un algoritmo basado en las especificaciones de Martin Porter
# 
# Para más información, visite:
# http://snowball.tartarus.org/algorithms/spanish/stemmer.html
#
# = License -- Licencia
# This code is provided under the terms of the {MIT License.}[http://www.opensource.org/licenses/mit-license.php]
#
# = Authors
#   * Manuel A. Güílamo maguilamo.c@gmail.com
#

module EStem
	##
	# For more information, please refer to <b>String#es_stem</b> method, also <b>EStem</b>.
	# :method: estem

	##
	#This method stem Spanish words.
	#
	#   "albergues".es_stem      # ==> "alberg"
	#   "habitaciones".es_stem   # ==> "habit"
	#   "ALbeRGues".es_stem      # ==> "ALbeRG"
	#   "HaBiTaCiOnEs".es_stem   # ==> "HaBiT"
	#   "Hacinamiento".es_stem   # ==> "Hacin"
	#
	#If you are not aware of the codeset the data have, try using
	#String#safe_es_stem instead.
	#
	#:call-seq:
	# str.es_stem    => "new_str"
	def es_stem
		str = self.dup
		case str.length
		when 0
			return str
		when 1
			return remove_accent(str)
		end

		step0(str)
		unless step1(str)
			step2b(str) unless step2a(str)
		end

		step3(str)
		remove_accent(str)
	end

	##
	#Use this method in case you are not aware of the codeset the data being
	#handle have. This method returns a new string with the same codeset as
	#the original. Be aware that this method is a bit slower than String#es_stem
	#:call-seq:
	# str.safe_es_stem    => "new_str"
	def safe_es_stem
		if self.encoding == Encoding::UTF_8
			# remove invalid characters
			return self.chars.select{|c| c.valid_encoding? }.join.es_stem
		end

		unless self.valid_encoding?
			tmp = self.dup
			if tmp.force_encoding('UTF-8').valid_encoding?
				begin
					return tmp.es_stem
				rescue
				end
			end
		end

		default_enc = self.encoding.name
		str = self.chars.select{|c| c.valid_encoding? }.join

		return nil if str.empty?

		begin
			tmp = str.encode('UTF-8', str.encoding.name).es_stem
			return tmp.encode(default_enc, 'UTF-8');
		rescue
			return nil
		end
	end

# :stopdoc:

	private

	def vowel?(c)
		VOWEL.include?(c)
	end

	def consonant?(c)
		CONSONANT.include?(c)
	end

	def remove_accent(str)
		str.tr('áéíóúÁÉÍÓÚ','aeiouAEIOU')
	end

	def rv(str)
		if consonant? str[1]
			i=2
			i+=1 while str[i] and consonant? str[i]
			return str.nil? ? str.length-1 : i+1
		end

		if vowel? str[0] and vowel? str[1]
			i=2
			i+=1 while str[i] and vowel? str[i]
			return str.nil? ? str.length-1 : i+1
		end

		return 3 if consonant? str[0] and vowel? str[1]

		str.length - 1
	end

	def r(str, i=0)
		i+=1 while str[i] and consonant?(str[i])
		i+=1
		i+=1 while str[i] and vowel? str[i]
		str[i].nil? ?  str.length : i+1
	end

	def r12(str)
		r1 = r(str)
		r2 = r(str,r1)
		[r1,r2]
	end

	#=> true or false
	def step0(str)
		return false unless str =~ /(se(l[ao]s?)?|l([aeo]s?)|me|nos)$/i

		suffix = $&
		rv_text = str[rv(str)..-1]

		case rv_text
		when %r{((?<=i[éÉ]ndo|[áÁ]ndo|[áéíÁÉÍ]r)#{suffix})$}ui
			str[%r{#$&$}]=''
			str.replace(remove_accent(str))
			return true
		when %r{((?<=iendo|ando|[aei]r)#{suffix})$}i
			str[%r{#$&$}]=''
			return true
		end

		if rv_text =~ /yendo/i and str =~ /uyendo/i
		      str[suffix]=''
		      return true
		end
		false
	end

	#=> true or false
	def step1(str)
		r1,r2 = r12(str)
		r1_text = str[r1..-1]
		r2_text = str[r2..-1]

		case r2_text
		when /(anzas?|ic[oa]s?|ismos?|[ai]bles?|istas?|os[oa]s?|[ai]mientos?)$/i
			str[%r{#$&$}]=''
			return true
		when /(ic)?(ador([ae]s?)?|aci[óÓ]n|aciones|antes?|ancias?)$/ui
			str[%r{#$&$}]=''
			return true
		when /log[íÍ]as?/ui
			str[%r{#$&$}]='log'
			return true
		when /(uci([óÓ]n|ones))$/ui
			str[%r{#$&$}]='u'
			return true
		when /(encias?)$/i
			str[%r{#$&$}]='ente'
			return true
		end

		if r2_text =~ /(ativ|iv|os|ic|ad)amente$/i or r1_text =~ /amente$/i
			str[%r{#$&$}]=''
			return true
		end

		case r2_text
		when /((ante|[ai]ble)?mente)$/i, /((abil|i[cv])?idad(es)?)$/i, /((at)?iv[ao]s?)$/i
			str[%r{#$&$}]=''
			return true
		end
		false
	end

	#=> true or false
	def step2a(str)
		rv_pos = rv(str)
		idx = str[rv_pos..-1] =~ /(y[oóÓ]|ye(ron|ndo)|y[ae][ns]?|ya(is|mos))$/ui

		return false unless idx

		if 'u' == str[rv_pos+idx-1].downcase
			str[%r{#$&$}] = ''
			return true
		end
		false
	end

	STEP2B_REGEXP = /(
		ar([áÁ][ns]?|a(n|s|is)?|on)? | ar([éÉ]is|emos|é|É) | ar[íÍ]a(n|s|is|mos)? |
		er([áÁ][sn]?|[éÉ](is)?|emos|[íÍ]a(n|s|is|mos)?)? |
		ir([íÍ]a(s|n|is|mos)?|[áÁ][ns]?|emos|[éÉ]|éis)? | aba(s|n|is)? |
		ad([ao]s?)? | ed | id(a|as|o|os)? | [íÍ]a(n|s|is|mos)? | [íÍ]s |
		as(e[ns]?|te|eis|teis)? | [áÁ](is|bamos|semos|ramos) | a(n|ndo|mos) |
		ie(ra|se|ran|sen|ron|ndo|ras|ses|rais|seis) | i(ste|steis|[óÓ]|mos|[éÉ]ramos|[éÉ]semos) |
		en|es|[éÉ]is|emos
	)$/xiu

	#=> true or false
	def step2b(str)
		rv_pos =  rv(str)

		if idx = str[rv_pos..-1] =~ STEP2B_REGEXP
			suffix = $&
			if suffix =~ /^(en|es|[éÉ]is|emos)$/ui
				str[%r{#{suffix}$}]=''
				str[rv_pos+idx-1]='' if str[rv_pos+idx-2] =~ /g/i and  str[rv_pos+idx-1] =~ /u/i
			else
				str[%r{#{suffix}$}]=''
			end
			return true
		end
		false
	end

	#=> true or false
	def step3(str)
		rv_pos = rv(str)
		rv_text = str[rv_pos..-1]

		if rv_text =~ /(os|[aoáíóÁÍÓ])$/ui
			str[%r{#$&$}]=''
			return true
		elsif idx = rv_text =~ /(u?[eéÉ])$/i
			if $&[0].downcase == 'u' and str[rv_pos+idx-1].downcase == 'g'
				str[%r{#$&$}]=''
			else
				str.chop!
			end
			return true
		end
		false
	end

	VOWEL = 'aeiouáéíóúüAEIOUÁÉÍÓÚÜ'
	CONSONANT = "bcdfghjklmnñpqrstvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ"
end

class String
	include EStem
end
