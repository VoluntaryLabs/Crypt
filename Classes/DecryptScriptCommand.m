#import "DecryptScriptCommand.h"
#import "Controller.h"

@implementation DecryptScriptCommand

- (id)performDefaultImplementation
{
	Controller *controller = [Controller mainController];
	BOOL result = YES;
		
	[controller setOptions:[self evaluatedArguments]];
	result = [controller decryptFile:[self directParameter]];

	return result ? @"yes" : @"no";
}

@end
