#!/usr/bin/env ruby
require 'gpgme'

ctx = GPGME::Ctx.new

passphrase_cb = proc {|hook, uid_hint, passphrase_info, prev_was_bad, fd|
  $stderr.write("Passphrase for #{uid_hint}: ")
  $stderr.flush
  begin
    system('stty -echo')
    io = IO.for_fd(fd, 'w')
    io.puts(gets.chomp)
    io.flush
  ensure
    system('stty echo')
  end
  puts
  GPGME::GPG_ERR_NO_ERROR
}
ctx.set_passphrase_cb(passphrase_cb)

begin
  pair = ctx.genkey(<<'EOF')
<GnupgKeyParms format="internal">
Key-Type: DSA
Key-Length: 1024
Subkey-Type: ELG-E
Subkey-Length: 1024
Name-Real: Joe Tester
Name-Comment: with stupid passphrase
Name-Email: joe@foo.bar
Passphrase: abcdabcdfs
Expire-Date: 2010-08-15
</GnupgKeyParms>
EOF
rescue GPGME::Error => err
  $stderr.puts(err.message)
  exit!
end

puts("Pubkey:\n#{pair[0].read}")
puts("Seckey:\n#{pair[1].read}")