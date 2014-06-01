
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

@protocol DragFileWellProtocol
- (void)droppedInWell:aWell;
- (BOOL)acceptsDropPaths:(NSArray *)paths;
@end

@interface DragFileWell : NSImageView
{
    NSArray *filePaths;
    IBOutlet id delegate;
    BOOL canDrag;
    BOOL canDrop;
    BOOL canDropMultiple;
}

- (void)canDrag:(BOOL)aBool;
- (void)canDrop:(BOOL)aBool;
- (void)canDropMultiple:(BOOL)aBool;

- (void)filePaths:(NSArray *)array;
- (NSArray *)filePaths;
- (NSImage *)image;

// -- dragging destination
- (BOOL)allowDropFrom:(NSPasteboard *)dragPasteboard;

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal;
- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender;
- (BOOL)draggingUpdated:(id <NSDraggingInfo>)sender;
- (void)draggingExited:(id <NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;

// delegate methods

// -- dragging source

@end
