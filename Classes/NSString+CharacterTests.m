//
//  NSString+CharacterTests.m
//  Crypt3
//
//  Created by Steve Dekorte on 7/28/14.
//
//

#import "NSString+CharacterTests.h"


@implementation NSString (CharacterTests)

extern char _passwdqc_wordset_4k[0x1000][6];

- (NSString *)username
{
	
	char *userName = (char *)getlogin();
	
	if (userName == NULL)
	{
		userName = getenv("LOGNAME");
	}
	
	if (userName == NULL)
	{
		userName = "";
	}
	
	return [NSString stringWithUTF8String:userName];
}


int strncmp_caseless(const char *a, const char *b, int n)
{
	while (*a && *b && n)
	{
		int d = abs(tolower(*a) - tolower(*b));
		
		if (d) return d;
		
		a ++;
		b ++;
		n --;
	}
	
	return n;
}

- (size_t)charactersInWords
{
	const char *s = [self UTF8String];
	int i;
	size_t count = 0;
	const char *username = [[self username] UTF8String];
	size_t wordCount = 0;
	
	while (*s)
	{
		int n;
		int max = 0;
		
		for (n = 0; n < 0x1000; n ++)
		{
			char *word = _passwdqc_wordset_4k[n];
			int wordLength = strlen(word);
			
			if (strncmp_caseless(s, word, wordLength) == 0)
			{
				if (max < wordLength) max = wordLength;
			}
		}
        
		if (strncmp_caseless(s, username, strlen(username)) == 0)
		{
			if (max < strlen(username)) max = strlen(username);
		}
		
		if (max)
		{
			s = s + max;
			count += max;
			wordCount ++;
		}
		else
		{
			s ++;
		}
	}
	
	//return count;
	{
        long r = (long)count - (long)(wordCount * 2);
        return r > 0 ? r : 0;
	}
}

- (size_t)charTypes
{
	const char *s = [self UTF8String];
	size_t count = 0;
	char c[256];
	
	memset(c, 0x0, 255);
	
	while (*s)
	{
		if (c[*s] != 1)
		{
			c[*s] = 1;
			count ++;
		}
		s ++;
	}
	
	return count;
}

- (size_t)digitCount
{
	const char *s = [self UTF8String];
	size_t count = 0;
	
	while (*s)
	{
		if (isdigit(*s)) count ++;
		s ++;
	}
	
	return count;
}

- (size_t)punctuationCount
{
	const char *s = [self UTF8String];
	size_t count = 0;
	
	while (*s)
	{
		if (ispunct(*s)) count ++;
		s ++;
	}
	
	return count;
}

- (size_t)lowerCount
{
	const char *s = [self UTF8String];
	size_t count = 0;
	
	while (*s)
	{
		if (isalpha(*s) && islower(*s)) count ++;
		s ++;
	}
	
	return count;
}

- (size_t)upperCount
{
	const char *s = [self UTF8String];
	size_t count = 0;
	
	while (*s)
	{
		if (isalpha(*s) && isupper(*s)) count ++;
		s ++;
	}
	
	return count;
}

- (size_t)alphaCount
{
	const char *s = [self UTF8String];
	size_t count = 0;
	
	while (*s)
	{
		if (isalpha(*s)) count ++;
		s ++;
	}
	
	return count;
}

@end
