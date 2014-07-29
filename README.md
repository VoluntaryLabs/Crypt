Crypt
=====

OSX desktop encryption app implemented as simple UI a wrapper around OpenSSL. 

All encryption and folder archiving are done by running a task which calls a command line script within the app wrapper (crypt3.sh) which uses tar, gzip and openssl.

A short suffix that is a hash of the encrypting password is included in the encrypted file suffix. This is long enough to use to effectively verify the password but short enough not to greatly reduce the encryption strength.

History
---------

I sold this app for a number of years but after reading about the unethical and criminal spying activities being done by various malicious government sponsored agencies, I've decided to make the it free and open source. Hope you find it useful.

- Steve
