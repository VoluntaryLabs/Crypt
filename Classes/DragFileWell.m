#import "DragFileWell.h"

@implementation DragFileWell

- (id)initWithFrame:(NSRect)frameRect
{
    [super initWithFrame:frameRect];
    [self setImageFrameStyle:NSImageFrameGrayBezel];
    [self setImageScaling:NSScaleToFit]; //NSScaleProportionally]; //NSScaleNone];
    
    canDrag = YES;
    canDrop = YES;
    canDropMultiple = YES;
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setImage:(NSImage *)image
{
    return;
}

- (void)awakeFromNib
{
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (void)canDrag:(BOOL)aBool
{
    canDrag = aBool;
}

- (void)canDrop:(BOOL)aBool
{
    canDrop = aBool;
}

- (void)canDropMultiple:(BOOL)aBool
{
    canDropMultiple = aBool;
}

- (void)filePaths:(NSArray *)array
{
    [filePaths autorelease];
    filePaths = [array retain];
    
    if (filePaths)
    {
        [self setImage:[self image]];
    }
    else
    {
        [self setImage:nil];
    }
}

- (NSArray *)filePaths
{
    return filePaths;
}

- (NSImage *)image
{
    return [[NSWorkspace sharedWorkspace] iconForFiles:filePaths];
}

/*
 drop methods
 1. draggingEntered
 2. draggingUpdated
 3. draggingExited
 4. prepareForDragOperation
 5. performDragOperation
 6. concludeDragOperation
 */

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
    return [self allowDropFrom:[sender draggingPasteboard]];
}

- (BOOL)allowDropFrom:(NSPasteboard *)dragPasteboard
{
    NSArray *types = [dragPasteboard types];
    NSArray *paths;
    //printf("draggingEntered:\n");
    
    if (!canDrop)
    {
        return NSDragOperationNone;
    }
    
    if (![types containsObject:NSFilenamesPboardType])
    {
        return NSDragOperationNone;
    }
    
    paths = [dragPasteboard propertyListForType:NSFilenamesPboardType];
    
    if ( (!canDropMultiple) && [paths count] !=1 )
    {
        return NSDragOperationNone;
    }
    
    if ([delegate respondsToSelector:@selector(acceptsDropPaths:)]
        && ![delegate acceptsDropPaths:paths])
    {
        return NSDragOperationNone;
    }
    
    [self setImage:[[NSWorkspace sharedWorkspace] iconForFiles:paths]];
    return NSDragOperationCopy;
}

- (BOOL)draggingUpdated:(id <NSDraggingInfo>)sender
{
    return [self allowDropFrom:[sender draggingPasteboard]];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    if (!canDrop)
    {
        return;
    }
    
    [self setImage:[self image]];
    //printf("draggingExited:\n");
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *dragPasteboard = [sender draggingPasteboard];
    NSArray *types = [dragPasteboard types];
    
    if ([self allowDropFrom:[sender draggingPasteboard]] == NSDragOperationNone)
    {
        return NO;
    }
    
    //printf("performDragOperation:\n");
    if ([types containsObject:NSFilenamesPboardType])
    {
        NSArray *paths = [dragPasteboard propertyListForType:NSFilenamesPboardType];
        [self filePaths:paths];
        
        if ([delegate respondsToSelector:@selector(droppedInWell:)])
        {
            [delegate droppedInWell:self];
        }
        //slideDraggedImageTo:
        return YES;
    }
    return NO;
}

// Dragging Source Methods

- (void)mouseDown:(NSEvent *)theEvent
{
    //NSSize dragOffset = NSMakeSize(0.0, 0.0);
    NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    NSPoint locationInWindow = [theEvent locationInWindow];
    NSPoint imageLocation;
    id image = [self image];
    [image setSize:[self frame].size];
    
    if (!canDrag)
    {
        return;
    }
    
    imageLocation.x = locationInWindow.x - [self frame].origin.x;
    imageLocation.y = locationInWindow.y - [self frame].origin.y;
    
    [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:self];
    [pboard setPropertyList:filePaths forType:NSFilenamesPboardType];
    //[pboard setData:[[self image] TIFFRepresentation] forType:NSTIFFPboardType];
    [self dragImage:[self image] at:imageLocation
             offset:NSMakeSize(0, 0) event:theEvent pasteboard:pboard source:self slideBack:YES];
}

// --

- (void)draggedImage:(NSImage *)anImage beganAt:(NSPoint)aPoint
{
}

- (void)draggedImage:(NSImage *)anImage
             endedAt:(NSPoint)aPoint
           operation:(NSDragOperation)operation
{
    //[self filePaths:nil];
    //[self setImage:nil];
    //if ([delegate respondsToSelector:@selector(droppedInWell:)])
    //{ [delegate draggedFromWell:self]; }
    //NSLog(@"%@", [filePaths description]);
}

- (void)draggedImage:(NSImage *)draggedImage
             movedTo:(NSPoint)screenPoint
{
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag
{
    if ((!canDrag) || flag)
    {
        return NSDragOperationNone;
    }
    
    return NSDragOperationCopy; //Generic;
}

- (BOOL)ignoreModifierKeysWhileDragging
{
    return YES;
}

@end
