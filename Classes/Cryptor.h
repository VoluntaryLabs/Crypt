
#import <Cocoa/Cocoa.h>

@interface Cryptor : NSObject 
{
	id delegate;
	NSTask *task;
	NSString *path;
	NSString *key;
	BOOL shredOriginal;
	BOOL didWork;
	BOOL skipChecks;
}

- (void)setDelegate:anObject;
- (void)setPath:(NSString *)path;
- (void)setKey:(NSString *)key;
- (void)setShredOriginal:(BOOL)b;
- (void)setSkipChecks:(BOOL)b;

- (void)encrypt;
- (void)decrypt;
- (BOOL)isValidPassword;

- (float)progress;
- (BOOL)isRunning;
- (void)stop;
- (BOOL)didWork;

@end
