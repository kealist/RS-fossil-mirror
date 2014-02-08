#!/usr/bin/env ruby

#	Fibonacci numbers
#	Copyright (c) 2012 Kaj de Vos
#	License: PD/CC0
#		http://creativecommons.org/publicdomain/zero/1.0/

Parameter = 40

def fibonacci n
	n < 2 ? n : fibonacci(n - 1) + fibonacci(n - 2)
end

start = Time.now

puts "Fibonacci #{Parameter}: #{fibonacci Parameter}"
puts "Elapsed time: #{Time.now - start}"
