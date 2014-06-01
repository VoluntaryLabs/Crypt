appPath := "."


"""
/openssl/libcrypto.0.9.8.dylib
/openssl/libssl.0.9.8.dylib
/openssl/openssl
""" split("\n") foreach(binPath,
	if(binPath strip isEmpty not,
		cmd := "/usr/bin/codesign --force --sign '3rd Party Mac Developer Application: Steve Dekorte' " .. (appPath .. binPath) asMutable removeSuffix("/")
		cmd println
		System system(cmd)
		writeln("next");
	)
)
/*

cmd := "productbuild --component '" .. appPath .. "' '/Applications' --sign '3rd Party Mac Developer Installer: Steve Dekorte' SoundConverter.pkg"
cmd println
System system(cmd)
*/