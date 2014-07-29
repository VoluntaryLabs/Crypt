//
//  NSString+CharacterTests.h
//  Crypt3
//
//  Created by Steve Dekorte on 7/28/14.
//
//

#import <Foundation/Foundation.h>

@interface NSString (CharacterTests)
- (size_t)charTypes;
- (size_t)digitCount;
- (size_t)punctuationCount;
- (size_t)lowerCount;
- (size_t)upperCount;
- (size_t)alphaCount;
@end
