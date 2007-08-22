/* vi:set ts=8 sts=4 sw=4 ft=objc:
 *
 * VIM - Vi IMproved		by Bram Moolenaar
 *				MacVim GUI port by Bjorn Winckler
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */

#import "MMTextView.h"
#import "MMTextStorage.h"
#import "MMWindowController.h"
#import "MMVimController.h"
#import "MacVim.h"



@interface MMTextView (Private)
- (BOOL)convertPoint:(NSPoint)point toRow:(int *)row column:(int *)column;
- (void)dispatchKeyEvent:(NSEvent *)event;
- (MMVimController *)vimController;
@end



@implementation MMTextView

- (void)dealloc
{
    [lastMouseDownEvent release];
    [super dealloc];
}

- (NSEvent *)lastMouseDownEvent
{
    return lastMouseDownEvent;
}

- (void)setShouldDrawInsertionPoint:(BOOL)enable
{
    shouldDrawInsertionPoint = enable;
}

- (BOOL)shouldDrawInsertionPoint
{
    return shouldDrawInsertionPoint;
}

- (void)insertText:(id)string
{
    // NOTE!  This method is called for normal key presses but also for
    // Option-key presses --- even when Ctrl is held as well as Option.  When
    // Ctrl is held, the AppKit translates the character to a Ctrl+key stroke,
    // so 'string' need not be a printable character!  In this case it still
    // works to pass 'string' on to Vim as a printable character (since
    // modifiers are already included and should not be added to the input
    // buffer using CSI, K_MODIFIER).

    NSEvent *event = [NSApp currentEvent];
    //NSLog(@"%s%@ (event=%@)", _cmd, string, event);

    // HACK!  In order to be able to bind to <S-Space> etc. we have to watch
    // for when space was pressed.
    if ([event type] == NSKeyDown
            && [[event charactersIgnoringModifiers] length] > 0
            && [[event charactersIgnoringModifiers] characterAtIndex:0] == ' '
            && [event modifierFlags]
                & (NSShiftKeyMask|NSControlKeyMask|NSAlternateKeyMask))
    {
        [self dispatchKeyEvent:event];
        return;
    }

    [NSCursor setHiddenUntilMouseMoves:YES];

    [[self vimController] sendMessage:InsertTextMsgID
                 data:[string dataUsingEncoding:NSUTF8StringEncoding]
                 wait:NO];
}


- (void)doCommandBySelector:(SEL)selector
{
    // By ignoring the selector we effectively disable the key binding
    // mechanism of Cocoa.  Hopefully this is what the user will expect
    // (pressing Ctrl+P would otherwise result in moveUp: instead of previous
    // match, etc.).
    //
    // We usually end up here if the user pressed Ctrl+key (but not
    // Ctrl+Option+key).

    //NSLog(@"%s%@", _cmd, NSStringFromSelector(selector));
    [self dispatchKeyEvent:[NSApp currentEvent]];
}

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
    // Called for Cmd+key keystrokes, function keys, arrow keys, page
    // up/down, home, end.

    if ([event type] != NSKeyDown)
        return NO;

    // HACK!  Let the main menu try to handle any key down event, before
    // passing it on to vim, otherwise key equivalents for menus will
    // effectively be disabled.
    if ([[NSApp mainMenu] performKeyEquivalent:event])
        return YES;

    // HACK!  KeyCode 50 represent the key which switches between windows
    // within an application (like Cmd+Tab is used to switch between
    // applications).  Return NO here, else the window switching does not work.
    //
    // Will this hack work for all languages / keyboard layouts?
    if ([event keyCode] == 50)
        return NO;

    //NSLog(@"%s%@", _cmd, event);

    NSString *string = [event charactersIgnoringModifiers];
    int flags = [event modifierFlags];
    int len = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *data = [NSMutableData data];

    [data appendBytes:&flags length:sizeof(int)];
    [data appendBytes:&len length:sizeof(int)];
    [data appendBytes:[string UTF8String] length:len];

    [[self vimController] sendMessage:CmdKeyMsgID data:data wait:NO];

    return YES;
}

- (void)setMarkedText:(id)text selectedRange:(NSRange)range
{
    // TODO: Figure out a way to handle marked text, at the moment the user
    // has no way of knowing what has been added so far in a multi-stroke key.
    // E.g. hitting Option-e and then e will result in an 'e' with acute, but
    // nothing is displayed immediately after hitting Option-e.

    NSLog(@"setMarkedText:'%@' selectedRange:(%d,%d)", text, range.location,
            range.length);
}

- (void)scrollWheel:(NSEvent *)event
{
    if ([event deltaY] == 0)
        return;

    int row, col;
    NSPoint pt = [self convertPoint:[event locationInWindow] fromView:nil];
    if (![self convertPoint:pt toRow:&row column:&col])
        return;

    int flags = [event modifierFlags];
    float dy = [event deltaY];
    NSMutableData *data = [NSMutableData data];

    [data appendBytes:&row length:sizeof(int)];
    [data appendBytes:&col length:sizeof(int)];
    [data appendBytes:&flags length:sizeof(int)];
    [data appendBytes:&dy length:sizeof(float)];

    [[self vimController] sendMessage:ScrollWheelMsgID data:data wait:NO];
}

- (void)mouseDown:(NSEvent *)event
{
    int row, col;
    NSPoint pt = [self convertPoint:[event locationInWindow] fromView:nil];
    if (![self convertPoint:pt toRow:&row column:&col])
        return;

    lastMouseDownEvent = [event copy];

    int button = [event buttonNumber];
    int flags = [event modifierFlags];
    int count = [event clickCount];
    NSMutableData *data = [NSMutableData data];

    // If desired, intepret Ctrl-Click as a right mouse click.
    if ([[NSUserDefaults standardUserDefaults]
            boolForKey:MMTranslateCtrlClickKey]
            && button == 0 && flags & NSControlKeyMask) {
        button = 1;
        flags &= ~NSControlKeyMask;
    }

    [data appendBytes:&row length:sizeof(int)];
    [data appendBytes:&col length:sizeof(int)];
    [data appendBytes:&button length:sizeof(int)];
    [data appendBytes:&flags length:sizeof(int)];
    [data appendBytes:&count length:sizeof(int)];

    [[self vimController] sendMessage:MouseDownMsgID data:data wait:NO];
}

- (void)rightMouseDown:(NSEvent *)event
{
    [self mouseDown:event];
}

- (void)otherMouseDown:(NSEvent *)event
{
    [self mouseDown:event];
}

- (void)mouseUp:(NSEvent *)event
{
    int row, col;
    NSPoint pt = [self convertPoint:[event locationInWindow] fromView:nil];
    if (![self convertPoint:pt toRow:&row column:&col])
        return;

    int flags = [event modifierFlags];
    NSMutableData *data = [NSMutableData data];

    [data appendBytes:&row length:sizeof(int)];
    [data appendBytes:&col length:sizeof(int)];
    [data appendBytes:&flags length:sizeof(int)];

    [[self vimController] sendMessage:MouseUpMsgID data:data wait:NO];
}

- (void)rightMouseUp:(NSEvent *)event
{
    [self mouseUp:event];
}

- (void)otherMouseUp:(NSEvent *)event
{
    [self mouseUp:event];
}

- (void)mouseDragged:(NSEvent *)event
{
    int row, col;
    NSPoint pt = [self convertPoint:[event locationInWindow] fromView:nil];
    if (![self convertPoint:pt toRow:&row column:&col])
        return;

    int flags = [event modifierFlags];
    NSMutableData *data = [NSMutableData data];

    [data appendBytes:&row length:sizeof(int)];
    [data appendBytes:&col length:sizeof(int)];
    [data appendBytes:&flags length:sizeof(int)];

    [[self vimController] sendMessage:MouseDraggedMsgID data:data wait:NO];
}

- (void)rightMouseDragged:(NSEvent *)event
{
    [self mouseDragged:event];
}

- (void)otherMouseDragged:(NSEvent *)event
{
    [self mouseDragged:event];
}

- (NSMenu*)menuForEvent:(NSEvent *)event
{
    // HACK! Return nil to disable NSTextView's popup menus (Vim provides its
    // own).  Called when user Ctrl-clicks in the view (this is already handled
    // in rightMouseDown:).
    return nil;
}

- (NSArray *)acceptableDragTypes
{
    return [NSArray arrayWithObjects:NSFilenamesPboardType,
           NSStringPboardType, nil];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];

    if ([[pboard types] containsObject:NSStringPboardType]) {
        NSString *string = [pboard stringForType:NSStringPboardType];
        NSMutableData *data = [NSMutableData data];
        int len = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;

        [data appendBytes:&len length:sizeof(int)];
        [data appendBytes:[string UTF8String] length:len];

        [[self vimController] sendMessage:DropStringMsgID data:data wait:NO];
        return YES;
    } else if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        int i, numberOfFiles = [files count];
        NSMutableData *data = [NSMutableData data];

        [data appendBytes:&numberOfFiles length:sizeof(int)];

#if 0
        int row, col;
        NSPoint pt = [self convertPoint:[sender draggingLocation] fromView:nil];
        if (![self convertPoint:pt toRow:&row column:&col])
            return NO;

        [data appendBytes:&row length:sizeof(int)];
        [data appendBytes:&col length:sizeof(int)];
#endif

        for (i = 0; i < numberOfFiles; ++i) {
            NSString *file = [files objectAtIndex:i];
            int len = [file lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

            if (len > 0) {
                ++len;  // append NUL as well
                [data appendBytes:&len length:sizeof(int)];
                [data appendBytes:[file UTF8String] length:len];
            }
        }

        [[self vimController] sendMessage:DropFilesMsgID data:data wait:NO];
        return YES;
    }

    return NO;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
    NSPasteboard *pboard = [sender draggingPasteboard];

    if ( [[pboard types] containsObject:NSFilenamesPboardType]
            && (sourceDragMask & NSDragOperationCopy) )
        return NSDragOperationCopy;
    if ( [[pboard types] containsObject:NSStringPboardType]
            && (sourceDragMask & NSDragOperationCopy) )
        return NSDragOperationCopy;

    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
    NSPasteboard *pboard = [sender draggingPasteboard];

    if ( [[pboard types] containsObject:NSFilenamesPboardType]
            && (sourceDragMask & NSDragOperationCopy) )
        return NSDragOperationCopy;
    if ( [[pboard types] containsObject:NSStringPboardType]
            && (sourceDragMask & NSDragOperationCopy) )
        return NSDragOperationCopy;

    return NSDragOperationNone;
}

- (void)changeFont:(id)sender
{
    MMTextStorage *ts = (MMTextStorage*)[self textStorage];
    if (!ts) return;

    NSFont *oldFont = [ts font];
    NSFont *newFont = [sender convertFont:oldFont];

    if (newFont) {
        NSString *name = [newFont displayName];
        unsigned len = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        if (len > 0) {
            NSMutableData *data = [NSMutableData data];
            float pointSize = [newFont pointSize];

            [data appendBytes:&pointSize length:sizeof(float)];

            ++len;  // include NUL byte
            [data appendBytes:&len length:sizeof(unsigned)];
            [data appendBytes:[name UTF8String] length:len];

            [[self vimController] sendMessage:SetFontMsgID data:data wait:NO];
        }
    }
}

- (void)resetCursorRects
{
    // No need to set up cursor rects...Vim is in control of cursor changes.
}

@end // MMTextView




@implementation MMTextView (Private)

- (BOOL)convertPoint:(NSPoint)point toRow:(int *)row column:(int *)column
{
    NSLayoutManager *lm = [self layoutManager];
    NSTextContainer *tc = [self textContainer];
    MMTextStorage *ts = (MMTextStorage*)[self textStorage];

    if (!(lm && tc && ts))
        return NO;

    unsigned glyphIdx = [lm glyphIndexForPoint:point inTextContainer:tc];
    unsigned charIdx = [lm characterIndexForGlyphAtIndex:glyphIdx];

    int mod = [ts maxColumns] + 1;

    if (row) *row = (int)(charIdx / mod);
    if (column) *column = (int)(charIdx % mod);

    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    // HACK! If a modifier is held, don't pass the event along to
    // interpretKeyEvents: since some keys are bound to multiple commands which
    // means doCommandBySelector: is called several times.
    //
    // TODO: Figure out a way to disable Cocoa key bindings entirely, without
    // affecting input management.

    if ([event modifierFlags] & NSControlKeyMask)
        [self dispatchKeyEvent:event];
    else
        [super keyDown:event];
}

- (void)dispatchKeyEvent:(NSEvent *)event
{
    // Only handle the command if it came from a keyDown event
    if ([event type] != NSKeyDown)
        return;

    NSString *chars = [event characters];
    NSString *imchars = [event charactersIgnoringModifiers];
    unichar c = [chars characterAtIndex:0];
    unichar imc = [imchars characterAtIndex:0];
    int len = 0;
    const char *bytes = 0;

    //NSLog(@"%s chars=0x%x unmodchars=0x%x", _cmd, c, imc);

    if (' ' == imc && 0xa0 != c) {
        // HACK!  The AppKit turns <C-Space> into <C-@> which is not standard
        // Vim behaviour, so bypass this problem.  (0xa0 is <M-Space>, which
        // should be passed on as is.)
        len = [imchars lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        bytes = [imchars UTF8String];
    } else if (imc == c && '2' == c) {
        // HACK!  Translate Ctrl+2 to <C-@>.
        static char ctrl_at = 0;
        len = 1;  bytes = &ctrl_at;
    } else if (imc == c && '6' == c) {
        // HACK!  Translate Ctrl+6 to <C-^>.
        static char ctrl_hat = 0x1e;
        len = 1;  bytes = &ctrl_hat;
    } else if (c == 0x19 && imc == 0x19) {
        // HACK! AppKit turns back tab into Ctrl-Y, so we need to handle it
        // separately (else Ctrl-Y doesn't work).
        static char back_tab[2] = { 'k', 'B' };
        len = 2; bytes = back_tab;
    } else if (c == 0x3 && imc == 0x3) {
        // HACK! AppKit turns enter (not return) into Ctrl-C, so we need to
        // handle it separately (else Ctrl-C doesn't work).
        static char enter[2] = { 'K', 'A' };
        len = 2; bytes = enter;
    } else {
        len = [chars lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        bytes = [chars UTF8String];
    }

    if (len > 0 && bytes) {
        NSMutableData *data = [NSMutableData data];
        int flags = [event modifierFlags];

        [data appendBytes:&flags length:sizeof(int)];
        [data appendBytes:&len length:sizeof(int)];
        [data appendBytes:bytes length:len];

        [NSCursor setHiddenUntilMouseMoves:YES];

        //NSLog(@"%s len=%d bytes=0x%x", _cmd, len, bytes[0]);
        [[self vimController] sendMessage:KeyDownMsgID data:data wait:NO];
    }
}

- (MMVimController *)vimController
{
    id windowController = [[self window] windowController];

    // TODO: Make sure 'windowController' is a MMWindowController before type
    // casting.
    return [(MMWindowController*)windowController vimController];
}

@end // MMTextView (Private)