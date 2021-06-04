#!/usr/bin/ruby

require 'digest'
require 'base58'

def usage
	puts "Usage: %s \"<hex-format-key>\"" % $0
	exit
end

# Read in the mini-private-key format key from command-line
if ! ARGV[0]
	usage
else
	hex = ARGV[0].downcase
end

if ! hex[/\h/]
	puts "Invalid hexadecimal value\n"
	usage
end
if  hex.to_i(16).size != 32
	puts "Hexadecimal value not 256 bits\n"
	usage
end

puts "Hex Format Key:  %s" % hex

# Prepend 0x80 to raw private key to indicate a mainnet address
extendedkey = '80' + hex
puts "Extended Key:  %s" % extendedkey

# Calculate the first hash
bytes = [extendedkey].pack('H*')
hash1 = Digest::SHA256.new
hash1.update(bytes)
puts "Extended Hash: %s" % hash1

# Calculate the checksum
bytes = [hash1.hexdigest].pack('H*')
hash2 = Digest::SHA256.new
hash2.update(bytes)
checksum = hash2.hexdigest[0..7]
puts "Checksum:      %s" % checksum

# Append the checksum to the extended key
preppedkey = extendedkey + checksum
puts "Prepped Key:   %s" % preppedkey

# Convert the prepped key into Base58Check encoding
bytes = [preppedkey].pack('H*')
wifkey = Base58.binary_to_base58(bytes, :bitcoin)
puts "WIF Key:       %s" % wifkey

