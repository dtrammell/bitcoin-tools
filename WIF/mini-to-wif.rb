#!/usr/bin/ruby

require 'digest'
require 'base58'


# Read in the mini-private-key format key from command-line
if ! ARGV[0]
	puts "Usage: %s \"<mini-format-key>\"" % $0
	exit
else
	mini = ARGV[0]
end
puts "Mini Format Key: %s" % mini

# Validate the mini-private-key format key
validation = mini + '?'
hash = Digest::SHA256.hexdigest(validation)
puts "Validation Hash: %s" % hash
puts "First Byte:      %s" % hash[0]
if hash[0].to_i != 0x00
	puts "Invalid mini-private-key format key."
	exit
else
	puts "Mini-private-key format key valid."
end

# Calculate the raw private key
privkey = Digest::SHA256.new
privkey.update( mini )
puts "Private Key:     %s" % privkey.hexdigest

# Prepend 0x80 to raw private key to indicate a mainnet address
extendedkey = '80' + privkey.hexdigest
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





