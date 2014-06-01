#import "EncryptScriptCommand.h"
#import "Controller.h"

@implementation EncryptScriptCommand

- (id)performDefaultImplementation
{
	Controller *controller = [Controller mainController];
	BOOL result = YES;
		
	[controller setOptions:[self evaluatedArguments]];
	result = [controller encryptFile:[self directParameter]];

	return result ? @"yes" : @"no";
}

@end
