
#import "Cryptor.h"

@implementation Cryptor

- (void)setDelegate:anObject
{
	delegate = anObject; // assume the delegate is the owner
}

- (void)setKey:(NSString *)aString
{
	[key autorelease];
	key = [aString retain];
}

- (void)setPath:(NSString *)p
{
	[path autorelease];
	path = [p retain];
}

- (void)setShredOriginal:(BOOL)b
{
	shredOriginal = b;
}

- (void)setSkipChecks:(BOOL)b
{
	skipChecks = b;
}

- (NSString *)openSslPath
{
	return [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"openssl"] stringByAppendingPathComponent:@"openssl"];
}

- (NSString *)scriptPath
{
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"crypt3.sh"];
}

- (void)encrypt
{
	NSArray *args = [NSArray arrayWithObjects:[self openSslPath], @"-encrypt", shredOriginal ? @"-delete" : @"-keep", key, path, nil];
	task = [NSTask launchedTaskWithLaunchPath:[self scriptPath] arguments:args];
	[task retain];
}

- (void)decrypt
{
	NSArray *args = [NSArray arrayWithObjects:[self openSslPath], @"-decrypt", 
		shredOriginal ? @"-delete" : @"-keep", 
		key, 
		path, 
		skipChecks ? @"skipChecks" : @"",
		nil];
	task = [NSTask launchedTaskWithLaunchPath:[self scriptPath] arguments:args];
	[task retain];
}

- (BOOL)isValidPassword
{
	NSArray *args = [NSArray arrayWithObjects:[self openSslPath], @"-decrypt", @"-testkey", key, path, nil];
	task = [NSTask launchedTaskWithLaunchPath:[self scriptPath] arguments:args];
	[task waitUntilExit];
	return (BOOL)[task terminationStatus];
}

- (void)stop
{
	if (task)
	{
		[task terminate];
		task = nil;
	}
}

- (BOOL)isRunning
{
	if (!task) 
	{
		return NO;
	}
	
	if ([task isRunning])
	{
		return YES;
	}
	else
	{
		printf("[task terminationStatus] = %i\n", [task terminationStatus]);
		didWork = ([task terminationStatus] == 0);
		[task release];
		task = nil;
		return NO;
	}
}

- (float)progress
{
	return 0.0;
}

- (BOOL)didWork
{
	return didWork;
}

@end
