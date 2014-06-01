#import <Cocoa/Cocoa.h>
#import "DragFileWell.h"
#import "Cryptor.h"
//#import "License.h"
//#import "validatereceipt.h"

@interface Controller : NSObject
{
    IBOutlet DragFileWell *inputWell;
    IBOutlet NSTextField *inputName;
    
    IBOutlet NSPanel *encryptPanel;
    IBOutlet NSTextField *encryptMessage;
    IBOutlet NSSecureTextField *encryptPassword;
    IBOutlet NSSecureTextField *encryptPassword2;
    IBOutlet NSButton *shredOriginal;
    
    IBOutlet NSButton *fileNamesOnly;
    IBOutlet NSButton *shredEncrypted;
    
    IBOutlet NSPanel *decryptPanel;
    IBOutlet NSTextField *decryptMessage;
    IBOutlet NSSecureTextField *decryptPassword;
    IBOutlet NSButton *remember;
    
    NSString *filePath;
    NSArray *filePaths;
    
    IBOutlet NSTextField *statusMessage;
    IBOutlet NSTextField *statusMessage2;
    IBOutlet NSProgressIndicator *progressBar;
    IBOutlet NSPanel *statusPanel;
    BOOL isCanceled;
    BOOL isEncrypting;
    BOOL dropLaunchStatus;
    
    /* for localization */
    IBOutlet NSTextField *encryptionPasswordLabel;
    IBOutlet NSTextField *encryptionPasswordLabel2;
    IBOutlet NSTextField *retypePasswordLabel;
    IBOutlet NSTextField *shred1Label;
    IBOutlet NSTextField *shred2Label;
    
    IBOutlet NSButton *cancel1Button;
    IBOutlet NSButton *encryptButton;
    IBOutlet NSButton *cancel2Button;
    IBOutlet NSButton *decryptButton;
    
    IBOutlet NSTextField *dropLabel;
    
    IBOutlet NSMenuItem *aboutMenu;
    IBOutlet NSMenuItem *feedbackMenu;
    IBOutlet NSMenuItem *tellAFriendMenu;
    IBOutlet NSMenuItem *webPageMenu;
    IBOutlet NSMenuItem *helpMenu;
    IBOutlet NSMenuItem *helpMenuItem;
    
    IBOutlet NSText *helpText;
    
    Cryptor *cryptor;
}

+ mainController;
- (void)setOptions:(NSDictionary *)options;

- (BOOL)acceptsDropPaths:(NSArray *)paths;
- (void)setFilePath:(NSString *)path;
- (NSString *)filePath;
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;
- (void)droppedInWell:(DragFileWell *)dragWell;
- (void)process;

- (BOOL)encryptFile:(NSString *)filePath;
//- (BOOL)password:(NSString *)password isValidForFile:(NSString *)filePath;
- (BOOL)decryptFile:(NSString *)filePath;
//- (void)dodShredFile:(NSString *)path message:(NSString *)message;

//- (IBAction)updateDeleteButton:sender;
//- (IBAction)updateDeleteEncryptedButton:sender;
- (void)doEncryption;
- (void)doDecryption;

- (IBAction)okEncryption:sender;
- (void)closeEncryptionPanel;
- (IBAction)cancelEncryption:sender;

- (IBAction)okDecryption:sender;
- (void)closeDecryptionPanel;
- (IBAction)cancelDecryption:sender;

- (void)openStatusPanel;
- (void)closeStatusPanel;

- (IBAction)playSoundClip:sender;
- (IBAction)cancelProcessing:sender;

- (BOOL)pathIsDirectory;

- (void)updateProgress:sender;
- (IBAction)cancel:sender;

@end
