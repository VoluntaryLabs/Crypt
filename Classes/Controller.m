#import "Controller.h"
#import "DragFileWell.h"
#import "NSString+CharacterTests.h"

#define CRYPT_SUFFIX @".crypt3"

static id mainController = nil;

@implementation Controller

+ mainController
{
	return mainController;
}

- init
{
	[super init];
	
	mainController = self;
	
	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		   selector:@selector(windowWillClose:) 
			  name:NSWindowWillCloseNotification 
			object:nil];
	
	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		   selector:@selector(appWillTerminate:) 
			  name:NSApplicationWillTerminateNotification 
			object:NSApp];
	
	cryptor = [[[Cryptor alloc] init] retain];
	return self;
}

- (void)awakeFromNib
{
	//License_exitIfNoLicense();

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[shredOriginal setIntValue:[defaults integerForKey:@"shredOriginal"]];
	[shredEncrypted setIntValue:[defaults integerForKey:@"shredEncrypted"]];
	
	[remember setIntValue:[defaults integerForKey:@"remember"]];
	[inputWell canDrag:NO];
	
	/* localization */
	
	[encryptionPasswordLabel setStringValue:NSLocalizedString(@"Encryption password:", nil)];
	[encryptionPasswordLabel2 setStringValue:NSLocalizedString(@"Encryption password:", nil)];
	[retypePasswordLabel     setStringValue:NSLocalizedString(@"Retype password:", nil)];
	[shred1Label             setStringValue:NSLocalizedString(@"Shred original:", nil)];
	[shred2Label             setStringValue:NSLocalizedString(@"Shred encrypted file:", nil)];
	
	[cancel1Button setTitle:NSLocalizedString(@"Cancel", nil)];
	[encryptButton setTitle:NSLocalizedString(@"Encrypt", nil)];
	[cancel2Button setTitle:NSLocalizedString(@"Cancel", nil)];
	[decryptButton setTitle:NSLocalizedString(@"Decrypt", nil)];
	
	[dropLabel setStringValue:NSLocalizedString(@"Drop items here to\n encrypt or decrypt", nil)];
	
	[aboutMenu setTitle:NSLocalizedString(@"About...", nil)];
	[feedbackMenu setTitle:NSLocalizedString(@"Feedback...", nil)];
	[tellAFriendMenu setTitle:NSLocalizedString(@"Tell a Friend...", nil)];
	[webPageMenu setTitle:NSLocalizedString(@"Web Page...", nil)];
	[helpMenu setTitle:NSLocalizedString(@"Help", nil)];
	[helpMenuItem setTitle:NSLocalizedString(@"Help", nil)];
	
	{
		NSString *path = [[NSBundle mainBundle] pathForResource:@"Help" ofType:@"rtf"];
		[helpText readRTFDFromFile:path];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	//NSRunAlertPanel(NSLocalizedString(@"Notes on using Crypt", nil), NSLocalizedString(@"It's important not to change the file suffix of the encrypted archive.", nil), NSLocalizedString(@"OK", nil), NSLocalizedString(@"Don't show this warning again", nil), nil);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:encryptPassword];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:encryptPassword2];
	return;
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	if ([aNotification object] == [inputWell window])
	{ 
		[NSApp terminate:nil]; 
	}
}

- (void)appWillTerminate:(NSNotification *)aNotification
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setInteger:[shredOriginal intValue] forKey:@"shredOriginal"];
	[defaults setInteger:[shredEncrypted intValue] forKey:@"shredEncrypted"];
	
	[defaults setInteger:[remember intValue] forKey:@"remember"];
	[defaults synchronize];
}

- (void)setFilePath:(NSString *)path
{
	[filePath autorelease];
	filePath = [path retain];
}

- (NSString *)filePath 
{ 
	return filePath; 
}

- (void)setFilePaths:(NSArray *)paths
{
	[filePaths autorelease];
	filePaths = [paths retain];
}

- (NSArray *)filePaths
{ 
	return filePaths; 
}

/*
 - (BOOL)application:(NSApplication *)sender openFileWithoutUI:(NSString *)filename
 {
	 printf("openFileWithoutUI\n");
	 return YES;
 }
 */


- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	BOOL isDir;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDir])
	{
		dropLaunchStatus = 1;
		[self setFilePath:filename];
		[self process];
		return YES;
	}
	
	return NO;
}

- (BOOL)allFilePathsOkForEncryption
{
	for(NSString *path in filePaths)
	{
		if ([path hasSuffix:CRYPT_SUFFIX] || [[self filePath] hasSuffix:@".crypt"]) return NO;
	}
	return YES;
}

- (BOOL)allFilePathsOkForDecryption
{
	for(NSString *path in filePaths)
	{
		if (![path hasSuffix:CRYPT_SUFFIX] || [[self filePath] hasSuffix:@".crypt"]) return NO;
	}
	return YES;
}


- (BOOL)acceptsDropPaths:(NSArray *)paths
{
	NSString *path = [paths lastObject];
	BOOL isDir;
	BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
	
	if (!result) 
	{ 
		[inputWell setImage:nil]; 
	}
	
	[self setFilePaths:paths];
	return result && ([self allFilePathsOkForEncryption] || [self allFilePathsOkForDecryption]);
	//return result;
}

- (void)droppedInWell:(DragFileWell *)dragWell
{ 
	dropLaunchStatus = 0;
	[self setFilePath:[[inputWell filePaths] lastObject]];
	[self setFilePaths:[inputWell filePaths]];
	[self process];
}

- (void)fileNamesProcess
{
	printf("file names process!\n");
}

- (void)process
{
	if ([[self filePath] hasSuffix:@".crypt"])
	{
		NSRunAlertPanel(NSLocalizedString(@"Sorry", nil), NSLocalizedString(@"Crypt3 does not work with files in the orginal .crypt format. Please use the original Crypt program to do that. Sorry for the lack of backwards compatability, but as I had very few donations I assume there weren't many people using the old format so it's not worth supporting.", nil), NSLocalizedString(@"OK", nil), nil, nil);
		return;
	}
	
	if ([[self filePath] hasSuffix:CRYPT_SUFFIX])
	{ 
		isEncrypting = NO; 
		[self doDecryption]; 
	} 
	else 
	{ 
		isEncrypting = YES; 
		[self doEncryption]; 
	}
	
	[inputWell setImage:nil];
	[inputName setStringValue:@""];
	[inputWell display];
}

- (size_t)sizeOfFileAtPath:(NSString *)path
{
	NSDictionary *fattrs = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:YES];
	return [[fattrs objectForKey:NSFileSize] intValue];
}

- (BOOL)hasResourceForkOnFilePath:(NSString *)path
{
	NSString *rPath = [path stringByAppendingPathComponent:@"rsrc"];
	NSDictionary *fattrs = [[NSFileManager defaultManager] fileAttributesAtPath:rPath traverseLink:YES];
	int size = [[fattrs objectForKey:NSFileSize] intValue];
	
	return (size > 0);
}

- (NSArray *)pathsWithResourceForksOnPath:(NSString *)path
{
	NSMutableArray *paths = [[[NSMutableArray alloc] init] autorelease];
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
	id file;
	
	while (file = [enumerator nextObject]) 
	{
		if ([self hasResourceForkOnFilePath:file])
		{
			[paths addObject:file];
		}
		
	}
	
	if ([self hasResourceForkOnFilePath:path])
	{
		[paths addObject:path];
	}	
	
	return paths;
}

- (BOOL)encryptFile:(NSString *)path
{
	//NSString *newName = [[path lastPathComponent] stringByAppendingString:CRYPT_SUFFIX];
	//NSString *newPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
	
	[statusMessage setStringValue:
		[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Encrypting", nil), [path lastPathComponent]]];
	[[statusMessage window] display];
	
	{
		if ([[self pathsWithResourceForksOnPath:path] count] > 0)
		{
			int choice = NSRunAlertPanel(NSLocalizedString(@"Warning", nil), NSLocalizedString(@"One or more of the files you requested to be encrypted contain resource forks. These forks will be lost in the encrypted archive. Are you sure you want to continue?", nil), NSLocalizedString(@"Continue", nil), NSLocalizedString(@"Cancel", nil), nil);
			if (choice != NSAlertDefaultReturn) 
			{ 
				[self closeStatusPanel];
				return NO; 
			}
		}
	}
	//printf("no resource forks found\n");
	
	{
		[cryptor setPath:path]; 
		[cryptor setDelegate:self]; 
		[cryptor setKey:[encryptPassword stringValue]];
		[cryptor setShredOriginal:[shredOriginal intValue] ? YES : NO];
		[cryptor encrypt];
		
		[self updateProgress:self];
	}
	
	return YES;
}

- (void)setOptions:(NSDictionary *)options
{
	[encryptPassword setStringValue:[options objectForKey:@"password"]];
	[shredOriginal setIntValue:[[options objectForKey:@"shredOriginal"] isEqual:@"yes"]];
}

- (BOOL)decryptFile:(NSString *)path
{	
	[statusMessage setStringValue:
		[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Decrypting", nil), [path lastPathComponent]]];
	[[statusMessage window] display];
	
	{
		[cryptor setDelegate:self]; 
		[cryptor setPath:path]; 
		[cryptor setKey:[decryptPassword stringValue]];
		//[cryptor setShredOriginal:[shredEncrypted intValue] ? YES : NO];
		[cryptor decrypt];
		[self updateProgress:self];
	}
	
	return YES;
}

- (void)doEncryption
{
    /*
	if ([self pathIsDirectory])
	{
		[[License sharedInstance] setMessage:
			NSLocalizedString(@"Encrypting a directory which requires a license", nil)];
		if (![[License sharedInstance] showLicensePanel]) return;
		License_exitIfNoLicense();
	}

	if ([self sizeOfFileAtPath:filePath] > 500000)
	{
		[[License sharedInstance] setMessage:
			NSLocalizedString(@"Encrypting a file larger than 500K requires a license", nil)];
		if (![[License sharedInstance] showLicensePanel]) return;
		License_exitIfNoLicense();
	}
    */
		
	[encryptMessage setStringValue:@""];
	[NSApp beginSheet:encryptPanel modalForWindow:[inputWell window]
	    modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		 contextInfo:nil];
}

- (void)doDecryption
{
	[decryptMessage setStringValue:@""];
	[NSApp beginSheet:decryptPanel modalForWindow:[inputWell window]
	    modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		 contextInfo:nil];
}

/*
 - (size_t)charTypes;
 - (size_t)digitCount;
 - (size_t)punctuationCount;
 - (size_t)lowerCount;
 - (size_t)upperCount;
 - (size_t)alphaCount;
 */



- (NSString *)passwordRating
{
	NSString *p = [encryptPassword stringValue];
	NSString *rating = @"";
	//double l = [p length];
	double t = 0;
	double r = 0;
	size_t charactersInWords = [p charactersInWords];
	
	//printf("charactersInWords = %i\n", (int)charactersInWords);
	
	if ([p digitCount]) t += 10;
	if ([p lowerCount]) t += 26;
	if ([p upperCount]) t += 26;
	if ([p punctuationCount]) t += 33;
	
	if ([p length] == 0)
	{
		return @"";
	}
	
	r = ([p length] - charactersInWords) * (t + [p charTypes]);

	if (r < 200) 
	{
		rating = @"insecure";
	}
	else if (r < 500) 
	{
		rating = @"still insecure";
	}
	else if (r < 800) 
	{
		rating =  @"ok";
	}
	else if (r < 1500) 
	{
		rating =  @"good";
	}
	else if (r < 2000) 
	{
		rating =  @"very good";
	}
	else
	{
		rating =  @"excellent";
	}	

	if ([p charTypes] < 7) 
	{
		rating = @"insecure";
	}			
	//return [NSString stringWithFormat:@"%i - %@", (int)r, rating];
	return [NSString stringWithFormat:@"%@", rating];

}	

- (void)controlTextDidChange:(NSNotification *)nd
{
	if ([[encryptPassword stringValue] length] == 0)
	{
		[encryptMessage setStringValue:@""];
	}
	else
	{
		[encryptMessage setStringValue:[NSString stringWithFormat:@"password rating: %@", [self passwordRating]]];
	}
	[encryptMessage display];
	
}

- (IBAction)okEncryption:sender
{
	if (![[encryptPassword stringValue] length])
	{
		[encryptPassword selectText:nil];
		[[encryptPassword window] makeFirstResponder:encryptPassword];
		[encryptMessage setStringValue:NSLocalizedString(@"need a password", nil)];
		return;
	}
	
	if (![[encryptPassword2 stringValue] length])
	{
		[encryptPassword2 selectText:nil];
		[[encryptPassword2 window] makeFirstResponder:encryptPassword2];
		[encryptMessage setStringValue:NSLocalizedString(@"retype password", nil)];
		return;
	}
	
	if (![[encryptPassword stringValue] isEqual:[encryptPassword2 stringValue]])
	{ 
		[encryptMessage setStringValue:NSLocalizedString(@"retyped password does not match", nil)]; 
		return;
	}
	
	[self closeEncryptionPanel]; 
	[self openStatusPanel];
	
    /*
	if ([self pathIsDirectory]) 
	{
		//if (![[License sharedInstance] hasValidLicense]) [NSApp terminate:nil];
		License_exitIfNoLicense();
	}
    */
	
	for(NSString *path in filePaths)
	{
		[self encryptFile:path];
	}
	
	[encryptPassword setStringValue:@""]; 
	[encryptPassword2 setStringValue:@""];
	[encryptMessage setStringValue:@""];
}

- (void)closeEncryptionPanel
{
	[NSApp endSheet:encryptPanel]; 
	[encryptPanel orderOut:self];
}

- (IBAction)cancelEncryption:sender
{
	[self closeEncryptionPanel];
}

- (IBAction)okDecryption:sender
{
	if (![[self filePath] hasSuffix:CRYPT_SUFFIX]) 
	{
		return;
	}
	
	[cryptor setKey:[decryptPassword stringValue]];
	[cryptor setPath:[self filePath]]; 
	[cryptor setShredOriginal:[shredEncrypted intValue] ? YES : NO];
	[cryptor setSkipChecks:NO];
	
	NSRange r1 = [[self filePath] rangeOfString:@".aes-256-cbc."]; 
	
	if(r1.location == NSNotFound)
	{
		int choice = NSRunAlertPanel(
			NSLocalizedString(@"Warning", nil), 
			NSLocalizedString(@"It appears the encrypted file name has been changed. The name contains the cipher used and a hash used to confirm the password. Attempt decryption anways and keep a copy of the original file? (there will be no output file if the wrong password is used)", nil), 
			NSLocalizedString(@"Attempt Decryption", nil), 
			NSLocalizedString(@"Cancel", nil), 
			nil);
			
		if (choice != NSAlertDefaultReturn) 
		{ 
			[self closeDecryptionPanel]; 
			return; 
		}
		[cryptor setSkipChecks:YES];
		[cryptor setShredOriginal:NO];
	}
	else if (![cryptor isValidPassword])
	{
		[decryptMessage setStringValue:NSLocalizedString(@"password not valid for file", nil)];
		return;
	}
	
	[self closeDecryptionPanel]; 
	[self openStatusPanel];
	
	for(NSString *path in filePaths)
	{
		[self decryptFile:[self filePath]];
	}
	
	[decryptPassword setStringValue:@""]; 
}

- (void)closeDecryptionPanel
{
	[NSApp endSheet:decryptPanel]; 
	[decryptPanel orderOut:self];
}

- (IBAction)cancelDecryption:sender
{
	[self closeDecryptionPanel];
}

- (void)openStatusPanel
{
	[statusMessage setStringValue:@""];
	[statusMessage2 setStringValue:@""];
	
	[progressBar setDoubleValue:0.0];
	[progressBar setUsesThreadedAnimation:YES];
	[progressBar startAnimation:nil];
	
	[NSApp beginSheet:statusPanel modalForWindow:[inputWell window]
	    modalDelegate:self
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		 contextInfo:nil];
}

- (void)closeStatusPanel
{
	[progressBar stopAnimation:nil];
	[NSApp endSheet:statusPanel]; 
	[statusPanel orderOut:self];
}

- (void)sheetDidEnd:(NSWindow *)sheet 
	    returnCode:(int)returnCode 
	   contextInfo:(void  *)contextInfo
{
}

- (IBAction)cancelProcessing:sender 
{ 
	isCanceled = YES; 
}

- (IBAction)playSoundClip:sender
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"cipher" ofType:@"wav"];
	NSSound *sound = [[NSSound alloc] initWithContentsOfFile:path byReference:YES];
	[sound play];
	[sound release];
}

- (BOOL)pathIsDirectory
{
	BOOL isDir;
	[[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
	return isDir;
}

- (void)updateProgress:sender
{
	if ([cryptor isRunning])
	{
		[[statusMessage window] display];
		[self performSelector:@selector(updateProgress:) withObject:self afterDelay:0.1];
		//[progressBar animate:self];
	}
	else
	{
		[self closeStatusPanel];
		/*
		NSLog(@"----- [cryptor didWork] = %i\n", [cryptor didWork]);
		if(![cryptor didWork])
		{
			int choice = NSRunAlertPanel(
				NSLocalizedString(@"Warning", nil), 
				NSLocalizedString(@"There was an error with the decryption. The original file was left unchanged.", nil), 
				NSLocalizedString(@"OK", nil), 
				nil, nil);
		}
		*/
		
		[[NSWorkspace sharedWorkspace] noteFileSystemChanged:filePath];
		/*
		 if (didDrop && [quitAfterShredding intValue])
		 {
			 [NSApp terminate:self];
		 }
		 */
	}
}

- (IBAction)cancel:sender
{
	[cryptor stop];
}

@end
