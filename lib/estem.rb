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

require 'iconv'

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
	#If you are not aware of the codeset the data has, then use
	#String#safe_es_stem instead.
	#
	#:call-seq:
	# str.es_stem    => "new_str"
	def es_stem
		str = self.dup
		return remove_accent(str) if str.length == 1
		tmp = step0(str)
		str = tmp ? tmp : str

		unless tmp = step1(str)
			unless tmp = step2a(str)
				tmp = step2b(str)
				str = tmp ? tmp : str
			else
				str = tmp
			end
		end
		tmp = step3(str)
		str = tmp.nil? ? str : tmp
		remove_accent(str)
	end

	##
	#Use this method in case you are not aware of the codeset the data being
	#handle has. This method returns a new string with the same codeset as
	#the original. Be aware that this method is slower than String#es_stem()
	#:call-seq:
	# str.safe_es_stem    => "new_str"
	def safe_es_stem
		return self.es_stem if self.encoding == Encoding::UTF_8

		default_enc = self.encoding.name

		str = self.dup.force_encoding('UTF-8')

		if str.valid_encoding?
			begin
				tmp = str.es_stem
				return tmp.force_encoding(default_enc)
			rescue
			end
		end

		if enc = Encoding.compatible?(self, VOWEL)
			begin
				return self.encode(enc).es_stem
			rescue
			end
		end

		begin
			tmp = Iconv.conv('UTF-8', self.encoding.name, self).es_stem
			return Iconv.conv(default_enc, 'UTF-8', tmp);
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

	def step0(str)
		return nil unless str =~ /(se(l[ao]s?)?|l([aeo]s?)|me|nos)$/i

		suffix = $&
		rv_text = str[rv(str)..-1]

		case rv_text
		when %r{((?<=i[éÉ]ndo|[áÁ]ndo|[áéíÁÉÍ]r)#{suffix})$}ui
			str[%r{#$&$}]=''
			str = remove_accent(str)
			return str
		when %r{((?<=iendo|ando|[aei]r)#{suffix})$}i
			str[%r{#$&$}]=''
			return str
		end

		if rv_text =~ /yendo/i and str =~ /uyendo/i
		      str[suffix]=''
		      return str
		end
		nil
	end

	#=> new_str or nil
	def step1(str)
		r1,r2 = r12(str)
		r1_text = str[r1..-1]
		r2_text = str[r2..-1]

		case r2_text
		when /(anzas?|ic[oa]s?|ismos?|[ai]bles?|istas?|os[oa]s?|[ai]mientos?)$/i
			str[%r{#$&$}]=''
			return str
		when /(ic)?(ador([ae]s?)?|aci[óÓ]n|aciones|antes?|ancias?)$/ui
			str[%r{#$&$}]=''
			return str
		when /log[íÍ]as?/ui
			str[%r{#$&$}]='log'
			return str
		when /(uci([óÓ]n|ones))$/ui
			str[%r{#$&$}]='u'
			return str
		when /(encias?)$/i
			str[%r{#$&$}]='ente'
			return str
		end

		if r2_text =~ /(ativ|iv|os|ic|ad)amente$/i or r1_text =~ /amente$/i
			str[%r{#$&$}]=''
			return str
		end

		case r2_text
		when /((ante|[ai]ble)?mente)$/i, /((abil|i[cv])?idad(es)?)$/i, /((at)?iv[ao]s?)$/i
			str[%r{#$&$}]=''
			return str
		end
		nil
	end

	#=> nil or new_str
	def step2a(str)
		rv_pos = rv(str)
		idx = str[rv_pos..-1] =~ /(y[oóÓ]|ye(ron|ndo)|y[ae][ns]?|ya(is|mos))$/ui

		return nil unless idx

		if 'u' == str[rv_pos+idx-1].downcase
			str[%r{#$&$}] = ''
			return str
		end
		nil
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
			return str
		end
		nil
	end

	def step3(str)
		rv_pos = rv(str)
		rv_text = str[rv_pos..-1]

		if rv_text =~ /(os|[aoáíóÁÍÓ])$/ui
			str[%r{#$&$}]=''
			return str
		elsif idx = rv_text =~ /(u?[eéÉ])$/i
			if $&[0].downcase == 'u' and str[rv_pos+idx-1].downcase == 'g'
				str[%r{#$&$}]=''
			else
				str.chop!
			end
			return str
		end
		nil
	end

	VOWEL = 'aeiouáéíóúüAEIOUÁÉÍÓÚÜ'
	CONSONANT = "bcdfghjklmnñpqrstvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ"
end

class String
	include EStem
end
