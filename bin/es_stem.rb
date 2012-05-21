#!/usr/bin/env ruby
# encoding: UTF-8

# Copyright (c) 2012 Manuel A. Güílamo
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'estem.rb'
require 'getoptlong'
require 'iconv'

$version = "0.1.9"

def usage(error=false)
	out = error ? $stderr : $stdout
	out.puts DATA.read()
end

opts = GetoptLong.new(
	['--help', '-h', GetoptLong::NO_ARGUMENT],
	['--version', '-v', GetoptLong::NO_ARGUMENT],
	['--file', '-f', GetoptLong::REQUIRED_ARGUMENT],
	['--in-enc', '-i', GetoptLong::REQUIRED_ARGUMENT],
	['--out-enc', '-o', GetoptLong::REQUIRED_ARGUMENT])

opts.quiet = true

filename = nil
ienc = nil
oenc = nil

begin
	opts.each do |op, arg|
		case op
		when '--help'
			usage()
			exit
		when '--version'
			puts "EStem\nSpanish stemmer // lexemador\nVer: #{$version}"
 			exit
		when '--file'
			filename = arg
		when '--in-enc'
			ienc =  arg
		when '--out-enc'
			oenc = arg
		end
	end
rescue GetoptLong::MissingArgument
	$stderr.puts 'Option requires an argument // La opción requiere un argumento'
	exit
rescue GetoptLong::InvalidOption
	$stderr.puts 'Unknown option // Opción desconocida.'
	usage(true)
	exit
rescue
	puts $!
	exit
end

if filename
	begin
		if ienc and ienc!='UTF-8'
			file = File.open(filename, "r:#{ienc}:UTF-8")
		else
			file = File.open(filename, 'r:UTF-8')
		end
	rescue
		$stderr.puts $!
		exit
	end

	begin
		hsh = {}
		file.each_line do|line|
			line.split(/[^a-záéíóúüñÁÉÍÓÚÜÑ]+/ui).each do|word|
				hsh[word] = word.es_stem unless hsh[word]
			end
		end
	rescue
		puts $!
		exit
	ensure
		file.close
	end
else
	hsh = {}
	$stdin.each_line do|line|
		if ienc
			line = Iconv.conv('UTF-8', ienc, line)
		else
			# Just in case the terminal mess with the encoding name.
			# Por si la terminal juega con el nombre de la codificación.
			line.force_encoding('UTF-8')
		end

		begin
			line.split(/[^a-záéíóúüñÁÉÍÓÚÜÑ]+/ui).each do|word|
				hsh[word] = word.es_stem unless hsh[word]
			end
		rescue Encoding::CompatibilityError
			if ienc
				msg = "incompatible encoding, please use option " +
				      "`--in-inc' correctly. //\n" +
				      "codificación incompatible, por favor use la " +
				      "opción `--in-inc' correctamente."
			else
				msg="incompatible encoding, please use option `--in-inc'."+
				    " //\ncodificación incompatible, por favor use la " +
				    "opción `--in-inc'."
			end

			if oenc
				msg = Iconv.conv(oenc, 'UTF-8', msg)
			end

			$stderr.puts msg
			exit
		rescue
			puts $!
			exit
		end
	end
end

if oenc
	begin
		hsh.each_pair do |k,v|
			puts Iconv.conv(oenc, 'UTF-8', "#{k} => #{v}")
		end
	rescue
		puts $!
		exit
	end
else
	hsh.each_pair{ |k,v| puts "#{k} => #{v}" }
end

__END__
Use: es_stem [OPTION]...

Options:
  --help, -h     display this help and exit. // Presenta esta ayuda y termina.
  --version, -v  output version information and exit //
                 Muestra la versión y termina.
  --file, -f     file of words. // fichero de palabras.
  --in-enc, -i   encoding of the file. // codificación del fichero.
  --out-enc, -o  output encoding // codificación de salida.

By default UTF-8 is used as input encoding, and if no file is specified,
standard input will be used instead.

You should set the option `--out-enc' if you are experimenting problems
visualizing the output text.

//

Por defecto se usará UTF-8 como codificación de entrada, si no se especifica un
fichero, la entrada estándard se usará en su lugar.

Debería establecer la opción `--out-enc' si está experimentando problemas para
visualizar el texto de salida.
