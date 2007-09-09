/* vi:set ts=8 sts=4 sw=4 ft=objc:
 *
 * VIM - Vi IMproved		by Bram Moolenaar
 *				MacVim GUI port by Bjorn Winckler
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */

#import <Foundation/Foundation.h>
#import "MMBackend.h"
#import "MacVim.h"
#import "vim.h"


static BOOL gui_macvim_is_valid_action(NSString *action);


// -- Initialization --------------------------------------------------------

/*
 * Parse the GUI related command-line arguments.  Any arguments used are
 * deleted from argv, and *argc is decremented accordingly.  This is called
 * when vim is started, whether or not the GUI has been started.
 */
    void
gui_mch_prepare(int *argc, char **argv)
{
    //NSLog(@"gui_mch_prepare(argc=%d)", *argc);

    // Set environment variables $VIM and $VIMRUNTIME
    // NOTE!  If vim_getenv is called with one of these as parameters before
    // they have been set here, they will most likely end up with the wrong
    // values!
    //
    // TODO:
    // - ensure this is called first to avoid above problem
    // - encoding

    NSString *path = [[[NSBundle mainBundle] resourcePath]
        stringByAppendingPathComponent:@"vim"];
    vim_setenv((char_u*)"VIM", (char_u*)[path UTF8String]);

    path = [path stringByAppendingPathComponent:@"runtime"];
    vim_setenv((char_u*)"VIMRUNTIME", (char_u*)[path UTF8String]);
}


/*
 * Check if the GUI can be started.  Called before gvimrc is sourced.
 * Return OK or FAIL.
 */
    int
gui_mch_init_check(void)
{
    //NSLog(@"gui_mch_init_check()");
    return OK;
}


/*
 * Initialise the GUI.  Create all the windows, set up all the call-backs etc.
 * Returns OK for success, FAIL when the GUI can't be started.
 */
    int
gui_mch_init(void)
{
    //NSLog(@"gui_mch_init()");

    if (![[MMBackend sharedInstance] checkin])
        return FAIL;

    // HACK!  Force the 'termencoding to utf-8.  For the moment also force
    // 'encoding', although this will change in the future.  The user can still
    // change 'encoding'; doing so WILL crash the program.
    set_option_value((char_u *)"termencoding", 0L, (char_u *)"utf-8", 0);
    set_option_value((char_u *)"encoding", 0L, (char_u *)"utf-8", 0);

    // Set values so that pixels and characters are in one-to-one
    // correspondence (assuming all characters have the same dimensions).
    gui.scrollbar_width = gui.scrollbar_height = 0;

    gui.char_height = 1;
    gui.char_width = 1;
    gui.char_ascent = 0;

    gui_mch_def_colors();

    [[MMBackend sharedInstance]
        setDefaultColorsBackground:gui.back_pixel foreground:gui.norm_pixel];
    [[MMBackend sharedInstance] setBackgroundColor:gui.back_pixel];
    [[MMBackend sharedInstance] setForegroundColor:gui.norm_pixel];

    // NOTE: If this call is left out the cursor is opaque.
    highlight_gui_started();

    return OK;
}



    void
gui_mch_exit(int rc)
{
    //NSLog(@"gui_mch_exit(rc=%d)", rc);

    [[MMBackend sharedInstance] exit];
}


/*
 * Open the GUI window which was created by a call to gui_mch_init().
 */
    int
gui_mch_open(void)
{
    //NSLog(@"gui_mch_open()");

    return [[MMBackend sharedInstance] openVimWindow];
}


// -- Updating --------------------------------------------------------------


/*
 * Catch up with any queued X events.  This may put keyboard input into the
 * input buffer, call resize call-backs, trigger timers etc.  If there is
 * nothing in the X event queue (& no timers pending), then we return
 * immediately.
 */
    void
gui_mch_update(void)
{
    // TODO: Ensure that this causes no problems.
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate distantPast]];
}


/* Flush any output to the screen */
    void
gui_mch_flush(void)
{
    [[MMBackend sharedInstance] flushQueue:NO];
}


/*
 * GUI input routine called by gui_wait_for_chars().  Waits for a character
 * from the keyboard.
 *  wtime == -1	    Wait forever.
 *  wtime == 0	    This should never happen.
 *  wtime > 0	    Wait wtime milliseconds for a character.
 * Returns OK if a character was found to be available within the given time,
 * or FAIL otherwise.
 */
    int
gui_mch_wait_for_chars(int wtime)
{
    // NOTE! In all likelihood Vim will take a nap when waitForInput: is
    // called, so force a flush of the command queue here.
    [[MMBackend sharedInstance] flushQueue:YES];

    return [[MMBackend sharedInstance] waitForInput:wtime];
}


// -- Drawing ---------------------------------------------------------------


/*
 * Clear the whole text window.
 */
    void
gui_mch_clear_all(void)
{
    [[MMBackend sharedInstance] clearAll];
}


/*
 * Clear a rectangular region of the screen from text pos (row1, col1) to
 * (row2, col2) inclusive.
 */
    void
gui_mch_clear_block(int row1, int col1, int row2, int col2)
{
    [[MMBackend sharedInstance] clearBlockFromRow:row1 column:col1
                                                    toRow:row2 column:col2];
}


/*
 * Delete the given number of lines from the given row, scrolling up any
 * text further down within the scroll region.
 */
    void
gui_mch_delete_lines(int row, int num_lines)
{
    [[MMBackend sharedInstance] deleteLinesFromRow:row count:num_lines
            scrollBottom:gui.scroll_region_bot
                    left:gui.scroll_region_left
                   right:gui.scroll_region_right];
}


    void
gui_mch_draw_string(int row, int col, char_u *s, int len, int flags)
{
    [[MMBackend sharedInstance] replaceString:(char*)s length:len
            row:row column:col flags:flags];
}


    int
gui_macvim_draw_string(int row, int col, char_u *s, int len, int flags)
{
#if 0
    NSString *string = [[NSString alloc]
            initWithBytesNoCopy:(void*)s
                         length:len
                       encoding:NSUTF8StringEncoding
                   freeWhenDone:NO];
    int cells = [string length];
    [string release];

    NSLog(@"gui_macvim_draw_string(row=%d, col=%d, len=%d, cells=%d, flags=%d)",
            row, col, len, cells, flags);

    [[MMBackend sharedInstance] replaceString:(char*)s length:len
            row:row column:col flags:flags];

    return cells;
#elif 0
    int c;
    int cn;
    int cl;
    int i;
    BOOL wide = NO;
    int start = 0;
    int endcol = col;
    int startcol = col;
    MMBackend *backend = [MMBackend sharedInstance];

    for (i = 0; i < len; i += cl) {
        c = utf_ptr2char(s + i);
        cl = utf_ptr2len(s + i);
        cn = utf_char2cells(c);
        comping = utf_iscomposing(c);

        if (!comping)
            endcol += cn;

        if (cn > 1 && !wide) {
            // Start of wide characters.
            wide = YES;

            // Output non-wide characters.
            if (start > i) {
                NSLog(@"Outputting %d non-wide chars (%d bytes)",
                        endcol-startcol, start-i);
                [backend replaceString:(char*)(s+start) length:start-i
                        row:row column:startcol flags:flags];
                startcol = endcol;
                start = i;
            }
        } else if (cn <= 1 && !comping && wide) {
            // End of wide characters.
            wide = NO;

            // Output wide characters.
            if (start > i) {
                NSLog(@"Outputting %d wide chars (%d bytes)",
                        endcol-startcol, start-i);
                [backend replaceString:(char*)(s+start) length:start-i
                        row:row column:startcol flags:(flags|0x80)];
                startcol = endcol;
                start = i;
            }
        }
    }

    // Output remaining characters.
    flags = wide ? flags|0x80 : flags;
    NSLog(@"Outputting %d %s chars (%d bytes)", endcol-startcol, wide ? "wide"
            : "non-wide", len-start);
    [backend replaceString:(char*)(s+start) length:len-start
            row:row column:startcol flags:flags];

    return endcol - col;
#elif 1
    //
    // Output chars until a wide char found.  If a wide char is found, output a
    // zero-width space after it so that a wide char looks like two chars to
    // MMTextStorage.  This way 1 char corresponds to 1 column.
    //

    int c;
    int cn;
    int cl;
    int i;
    int start = 0;
    int endcol = col;
    int startcol = col;
    BOOL outPad = NO;
    MMBackend *backend = [MMBackend sharedInstance];
    static char ZeroWidthSpace[] = { 0xe2, 0x80, 0x8b };
#if MM_ENABLE_CONV
    char_u *conv_str = NULL;

    if (output_conv.vc_type != CONV_NONE) {
        char_u *conv_str = string_convert(&output_conv, s, &len);
        if (conv_str)
            s = conv_str;
    }
#endif

    for (i = 0; i < len; i += cl) {
        c = utf_ptr2char(s + i);
        cl = utf_ptr2len(s + i);
        cn = utf_char2cells(c);

        if (!utf_iscomposing(c)) {
            if (outPad) {
                outPad = NO;
#if 0
                NSString *string = [[NSString alloc]
                        initWithBytesNoCopy:(void*)(s+start)
                                     length:i-start
                                   encoding:NSUTF8StringEncoding
                               freeWhenDone:NO];
                NSLog(@"Flushing string=%@ len=%d row=%d col=%d end=%d",
                        string, i-start, row, startcol, endcol);
                [string release];
#endif
                [backend replaceString:(char*)(s+start) length:i-start
                        row:row column:startcol flags:flags];
                start = i;
                startcol = endcol;
#if 0
                NSLog(@"Padding len=%d row=%d col=%d", sizeof(ZeroWidthSpace),
                        row, endcol-1);
#endif
                [backend replaceString:ZeroWidthSpace
                             length:sizeof(ZeroWidthSpace)
                        row:row column:endcol-1 flags:flags];
            }

            endcol += cn;
        }

        if (cn > 1) {
#if 0
            NSLog(@"Wide char detected! (char=%C hex=%x cells=%d)", c, c, cn);
#endif
            outPad = YES;
        }
    }

#if 0
    if (row < 1) {
        NSString *string = [[NSString alloc]
                initWithBytesNoCopy:(void*)(s+start)
                             length:len-start
                           encoding:NSUTF8StringEncoding
                       freeWhenDone:NO];
        NSLog(@"Output string=%@ len=%d row=%d col=%d", string, len-start, row,
                startcol);
        [string release];
    }
#endif

    // Output remaining characters.
    [backend replaceString:(char*)(s+start) length:len-start
            row:row column:startcol flags:flags];

    if (outPad) {
#if 0
        NSLog(@"Padding len=%d row=%d col=%d", sizeof(ZeroWidthSpace), row,
                endcol-1);
#endif
        [backend replaceString:ZeroWidthSpace
                     length:sizeof(ZeroWidthSpace)
                row:row column:endcol-1 flags:flags];
    }

#if MM_ENABLE_CONV
    if (conv_str)
        vim_free(conv_str);
#endif

    return endcol - col;
#else
    // This will fail abysmally when wide or composing characters are used.
    [[MMBackend sharedInstance]
            replaceString:(char*)s length:len row:row column:col flags:flags];

    int i, c, cl, cn, cells = 0;
    for (i = 0; i < len; i += cl) {
        c = utf_ptr2char(s + i);
        cl = utf_ptr2len(s + i);
        cn = utf_char2cells(c);

        if (!utf_iscomposing(c))
            cells += cn;
    }

    return cells;
#endif
}


/*
 * Insert the given number of lines before the given row, scrolling down any
 * following text within the scroll region.
 */
    void
gui_mch_insert_lines(int row, int num_lines)
{
    [[MMBackend sharedInstance] insertLinesFromRow:row count:num_lines
            scrollBottom:gui.scroll_region_bot
                    left:gui.scroll_region_left
                   right:gui.scroll_region_right];
}


/*
 * Set the current text foreground color.
 */
    void
gui_mch_set_fg_color(guicolor_T color)
{
    [[MMBackend sharedInstance] setForegroundColor:color];
}


/*
 * Set the current text background color.
 */
    void
gui_mch_set_bg_color(guicolor_T color)
{
    [[MMBackend sharedInstance] setBackgroundColor:color];
}


/*
 * Set the current text special color (used for underlines).
 */
    void
gui_mch_set_sp_color(guicolor_T color)
{
    [[MMBackend sharedInstance] setSpecialColor:color];
}


/*
 * Set default colors.
 */
    void
gui_mch_def_colors()
{
    MMBackend *backend = [MMBackend sharedInstance];

    // The default colors are taken from system values
    gui.def_norm_pixel = gui.norm_pixel = 
        [backend lookupColorWithKey:@"MacTextColor"];
    gui.def_back_pixel = gui.back_pixel = 
        [backend lookupColorWithKey:@"MacTextBackgroundColor"];

    // Set the text selection color to match the system preferences.
    // TODO: Is there a better way to do this?
    do_cmdline_cmd((char_u*)"hi Visual guibg=MacSelectedTextBackgroundColor");
}


/*
 * Called when the foreground or background color has been changed.
 */
    void
gui_mch_new_colors(void)
{
    gui.def_back_pixel = gui.back_pixel;
    gui.def_norm_pixel = gui.norm_pixel;

    //NSLog(@"gui_mch_new_colors(back=%x, norm=%x)", gui.def_back_pixel,
    //        gui.def_norm_pixel);

    [[MMBackend sharedInstance]
        setDefaultColorsBackground:gui.def_back_pixel
                        foreground:gui.def_norm_pixel];
}


// -- Tabline ---------------------------------------------------------------


/*
 * Set the current tab to "nr".  First tab is 1.
 */
    void
gui_mch_set_curtab(int nr)
{
    [[MMBackend sharedInstance] selectTab:nr];
}


/*
 * Return TRUE when tabline is displayed.
 */
    int
gui_mch_showing_tabline(void)
{
    return [[MMBackend sharedInstance] tabBarVisible];
}

/*
 * Update the labels of the tabline.
 */
    void
gui_mch_update_tabline(void)
{
    [[MMBackend sharedInstance] updateTabBar];
}

/*
 * Show or hide the tabline.
 */
    void
gui_mch_show_tabline(int showit)
{
    [[MMBackend sharedInstance] showTabBar:showit];
}


// -- Clipboard -------------------------------------------------------------


    void
clip_mch_lose_selection(VimClipboard *cbd)
{
}


    int
clip_mch_own_selection(VimClipboard *cbd)
{
    return 0;
}


    void
clip_mch_request_selection(VimClipboard *cbd)
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSString *pbType = [pb availableTypeFromArray:
            [NSArray arrayWithObject:NSStringPboardType]];
    if (pbType) {
        NSMutableString *string =
                [[pb stringForType:NSStringPboardType] mutableCopy];

        // Replace unrecognized end-of-line sequences with \x0a (line feed).
        NSRange range = { 0, [string length] };
        unsigned n = [string replaceOccurrencesOfString:@"\x0d\x0a"
                                             withString:@"\x0a" options:0
                                                  range:range];
        if (0 == n) {
            n = [string replaceOccurrencesOfString:@"\x0d" withString:@"\x0a"
                                           options:0 range:range];
        }
        
        // Scan for newline character to decide whether the string should be
        // pasted linewise or characterwise.
        int type = MCHAR;
        if (0 < n || NSNotFound != [string rangeOfString:@"\n"].location)
            type = MLINE;

        char_u *str = (char_u*)[string UTF8String];
        int len = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

#if MM_ENABLE_CONV
        if (input_conv.vc_type != CONV_NONE) {
            NSLog(@"Converting from: '%@'", string);
            char_u *conv_str = string_convert(&input_conv, str, &len);
            if (conv_str) {
                NSLog(@"           to: '%s'", conv_str);
                clip_yank_selection(type, conv_str, len, cbd);
                vim_free(conv_str);
                return;
            }
        }
#endif

        clip_yank_selection(type, str, len, cbd);
    }
}


/*
 * Send the current selection to the clipboard.
 */
    void
clip_mch_set_selection(VimClipboard *cbd)
{
    // If the '*' register isn't already filled in, fill it in now.
    cbd->owned = TRUE;
    clip_get_selection(cbd);
    cbd->owned = FALSE;
    
    // Get the text to put on the pasteboard.
    long_u llen = 0; char_u *str = 0;
    int type = clip_convert_selection(&str, &llen, cbd);
    if (type < 0)
        return;

    // TODO: Avoid overflow.
    int len = (int)llen;
#if MM_ENABLE_CONV
    if (output_conv.vc_type != CONV_NONE) {
        char_u *conv_str = string_convert(&output_conv, str, &len);
        if (conv_str) {
            vim_free(str);
            str = conv_str;
        }
    }
#endif

    if (len > 0) {
        NSString *string = [[NSString alloc]
            initWithBytes:str length:len encoding:NSUTF8StringEncoding];

        NSPasteboard *pb = [NSPasteboard generalPasteboard];
        [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType]
                   owner:nil];
        [pb setString:string forType:NSStringPboardType];
        
        [string release];
    }

    vim_free(str);
}


// -- Menu ------------------------------------------------------------------


/*
 * Add a sub menu to the menu bar.
 */
    void
gui_mch_add_menu(vimmenu_T *menu, int idx)
{
    // HACK!  If menu has no parent, then we set the parent tag to the type of
    // menu it is.  This will not mix up tag and type because pointers can not
    // take values close to zero (and the tag is simply the value of the
    // pointer).
    int parent = (int)menu->parent;
    if (!parent) {
        parent = menu_is_popup(menu->name) ? MenuPopupType :
                 menu_is_toolbar(menu->name) ? MenuToolbarType :
                 MenuMenubarType;
    }

    [[MMBackend sharedInstance]
            addMenuWithTag:(int)menu parent:parent name:(char*)menu->dname
                   atIndex:idx];
}


/*
 * Add a menu item to a menu
 */
    void
gui_mch_add_menu_item(vimmenu_T *menu, int idx)
{
    // NOTE!  If 'iconfile' is not set but 'iconidx' is, use the name of the
    // menu item.  (Should correspond to a stock item.)
    char *icon = menu->iconfile ? (char*)menu->iconfile :
                 menu->iconidx >= 0 ? (char*)menu->dname :
                 NULL;
    //char *name = menu_is_separator(menu->name) ? NULL : (char*)menu->dname;
    char *name = (char*)menu->dname;
    char *tip = menu->strings[MENU_INDEX_TIP]
            ? (char*)menu->strings[MENU_INDEX_TIP] : (char*)menu->actext;

    // HACK!  Check if menu is mapped to ':action actionName:'; if so, pass the
    // action along so that MacVim can bind the menu item to this action.  This
    // means that if a menu item maps to an action in normal mode, then all
    // other modes will also use the same action.
    NSString *action = nil;
    char_u *map_str = menu->strings[MENU_INDEX_NORMAL];
    if (map_str) {
        NSString *mapping = [NSString stringWithCString:(char*)map_str
                                               encoding:NSUTF8StringEncoding];
        NSArray *parts = [mapping componentsSeparatedByString:@" "];
        if ([parts count] >=2 
                && [[parts objectAtIndex:0] isEqual:@":action"]) {
            action = [parts objectAtIndex:1];
            action = [action stringByTrimmingCharactersInSet:
                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (!gui_macvim_is_valid_action(action))
                action = nil;
        }
    }

    [[MMBackend sharedInstance]
            addMenuItemWithTag:(int)menu
                        parent:(int)menu->parent
                          name:name
                           tip:tip
                          icon:(char*)icon
                 keyEquivalent:menu->ke_key
                     modifiers:menu->ke_mods
                        action:action
                       atIndex:idx];
}


/*
 * Destroy the machine specific menu widget.
 */
    void
gui_mch_destroy_menu(vimmenu_T *menu)
{
    [[MMBackend sharedInstance] removeMenuItemWithTag:(int)menu];
}


/*
 * Make a menu either grey or not grey.
 */
    void
gui_mch_menu_grey(vimmenu_T *menu, int grey)
{
    [[MMBackend sharedInstance]
            enableMenuItemWithTag:(int)menu state:!grey];
}


/*
 * Make menu item hidden or not hidden
 */
    void
gui_mch_menu_hidden(vimmenu_T *menu, int hidden)
{
    // HACK! There is no (obvious) way to hide a menu item, so simply
    // enable/disable it instead.
    [[MMBackend sharedInstance]
            enableMenuItemWithTag:(int)menu state:!hidden];
}


/*
 * This is called when user right clicks.
 */
    void
gui_mch_show_popupmenu(vimmenu_T *menu)
{
    [[MMBackend sharedInstance] showPopupMenuWithName:(char*)menu->name
                                      atMouseLocation:YES];
}


/*
 * This is called when a :popup command is executed.
 */
    void
gui_make_popup(char_u *path_name, int mouse_pos)
{
    [[MMBackend sharedInstance] showPopupMenuWithName:(char*)path_name
                                      atMouseLocation:mouse_pos];
}


/*
 * This is called after setting all the menus to grey/hidden or not.
 */
    void
gui_mch_draw_menubar(void)
{
    // The (main) menu draws itself in Mac OS X.
}


    void
gui_mch_enable_menu(int flag)
{
    // The (main) menu is always enabled in Mac OS X.
}


#if 0
    void
gui_mch_set_menu_pos(int x, int y, int w, int h)
{
    // The (main) menu cannot be moved in Mac OS X.
}
#endif


    void
gui_mch_show_toolbar(int showit)
{
    int flags = 0;
    if (toolbar_flags & TOOLBAR_TEXT) flags |= ToolbarLabelFlag;
    if (toolbar_flags & TOOLBAR_ICONS) flags |= ToolbarIconFlag;
    if (tbis_flags & (TBIS_MEDIUM|TBIS_LARGE)) flags |= ToolbarSizeRegularFlag;

    [[MMBackend sharedInstance] showToolbar:showit flags:flags];
}




// -- Fonts -----------------------------------------------------------------


/*
 * If a font is not going to be used, free its structure.
 */
    void
gui_mch_free_font(font)
    GuiFont	font;
{
}


/*
 * Get a font structure for highlighting.
 */
    GuiFont
gui_mch_get_font(char_u *name, int giveErrorIfMissing)
{
    //NSLog(@"gui_mch_get_font(name=%s, giveErrorIfMissing=%d)", name,
    //        giveErrorIfMissing);
    return 0;
}


#if defined(FEAT_EVAL) || defined(PROTO)
/*
 * Return the name of font "font" in allocated memory.
 * Don't know how to get the actual name, thus use the provided name.
 */
    char_u *
gui_mch_get_fontname(GuiFont font, char_u *name)
{
    //NSLog(@"gui_mch_get_fontname(font=%d, name=%s)", font, name);
    return 0;
}
#endif


/*
 * Initialise vim to use the font with the given name.	Return FAIL if the font
 * could not be loaded, OK otherwise.
 */
    int
gui_mch_init_font(char_u *font_name, int fontset)
{
    //NSLog(@"gui_mch_init_font(font_name=%s, fontset=%d)", font_name, fontset);

    // HACK!  This gets called whenever the user types :set gfn=fontname, so
    // for now we set the font here.
    // TODO!  Proper font handling, the way Vim expects it.
    return [[MMBackend sharedInstance]
            setFontWithName:(char*)font_name];
}


/*
 * Set the current text font.
 */
    void
gui_mch_set_font(GuiFont font)
{
}


// -- Scrollbars ------------------------------------------------------------


    void
gui_mch_create_scrollbar(
	scrollbar_T *sb,
	int orient)	/* SBAR_VERT or SBAR_HORIZ */
{
    [[MMBackend sharedInstance] 
            createScrollbarWithIdentifier:sb->ident type:sb->type];
}


    void
gui_mch_destroy_scrollbar(scrollbar_T *sb)
{
    [[MMBackend sharedInstance] 
            destroyScrollbarWithIdentifier:sb->ident];
}


    void
gui_mch_enable_scrollbar(
	scrollbar_T	*sb,
	int		flag)
{
    [[MMBackend sharedInstance] 
            showScrollbarWithIdentifier:sb->ident state:flag];
}


    void
gui_mch_set_scrollbar_pos(
	scrollbar_T *sb,
	int x,
	int y,
	int w,
	int h)
{
    int pos = y;
    int len = h;
    if (SBAR_BOTTOM == sb->type) {
        pos = x;
        len = w; 
    }

    [[MMBackend sharedInstance] 
            setScrollbarPosition:pos length:len identifier:sb->ident];
}


    void
gui_mch_set_scrollbar_thumb(
	scrollbar_T *sb,
	long val,
	long size,
	long max)
{
    [[MMBackend sharedInstance] 
            setScrollbarThumbValue:val size:size max:max identifier:sb->ident];
}


// -- Cursor ----------------------------------------------------------------


/*
 * Draw a cursor without focus.
 */
    void
gui_mch_draw_hollow_cursor(guicolor_T color)
{
    return [[MMBackend sharedInstance]
        drawCursorAtRow:gui.row column:gui.col shape:MMInsertionPointHollow
               fraction:100 color:color];
}


/*
 * Draw part of a cursor, only w pixels wide, and h pixels high.
 */
    void
gui_mch_draw_part_cursor(int w, int h, guicolor_T color)
{
    // HACK!  'w' and 'h' are always 1 since we do not tell Vim about the exact
    // font dimensions.  Thus these parameters are useless.  Instead we look at
    // the shape_table to determine the shape and size of the cursor (just like
    // gui_update_cursor() does).
    int idx = get_shape_idx(FALSE);
    int shape = MMInsertionPointBlock;
    switch (shape_table[idx].shape) {
        case SHAPE_HOR: shape = MMInsertionPointHorizontal; break;
        case SHAPE_VER: shape = MMInsertionPointVertical; break;
    }

    return [[MMBackend sharedInstance]
        drawCursorAtRow:gui.row column:gui.col shape:shape
               fraction:shape_table[idx].percentage color:color];
}


/*
 * Cursor blink functions.
 *
 * This is a simple state machine:
 * BLINK_NONE	not blinking at all
 * BLINK_OFF	blinking, cursor is not shown
 * BLINK_ON blinking, cursor is shown
 */
    void
gui_mch_set_blinking(long wait, long on, long off)
{
    [[MMBackend sharedInstance] setBlinkWait:wait on:on off:off];
}


/*
 * Start the cursor blinking.  If it was already blinking, this restarts the
 * waiting time and shows the cursor.
 */
    void
gui_mch_start_blink(void)
{
    [[MMBackend sharedInstance] startBlink];
}


/*
 * Stop the cursor blinking.  Show the cursor if it wasn't shown.
 */
    void
gui_mch_stop_blink(void)
{
    [[MMBackend sharedInstance] stopBlink];
}


// -- Mouse -----------------------------------------------------------------


/*
 * Get current mouse coordinates in text window.
 */
    void
gui_mch_getmouse(int *x, int *y)
{
    //NSLog(@"gui_mch_getmouse()");
}


    void
gui_mch_setmouse(int x, int y)
{
    //NSLog(@"gui_mch_setmouse(x=%d, y=%d)", x, y);
}


    void
mch_set_mouse_shape(int shape)
{
    [[MMBackend sharedInstance] setMouseShape:shape];
}




// -- Unsorted --------------------------------------------------------------


    void
ex_action(eap)
    exarg_T	*eap;
{
    if (!gui.in_use) {
        EMSG(_("E???: Command only available in GUI mode"));
        return;
    }

    NSString *name = [NSString stringWithCString:(char*)eap->arg
                                        encoding:NSUTF8StringEncoding];
    if (gui_macvim_is_valid_action(name)) {
        [[MMBackend sharedInstance] executeActionWithName:name];
    } else {
        EMSG2(_("E???: \"%s\" is not a valid action"), eap->arg);
    }
}


/*
 * Adjust gui.char_height (after 'linespace' was changed).
 */
    int
gui_mch_adjust_charheight(void)
{
    [[MMBackend sharedInstance] adjustLinespace:p_linespace];
    return OK;
}


    void
gui_mch_beep(void)
{
}



#ifdef FEAT_BROWSE
/*
 * Pop open a file browser and return the file selected, in allocated memory,
 * or NULL if Cancel is hit.
 *  saving  - TRUE if the file will be saved to, FALSE if it will be opened.
 *  title   - Title message for the file browser dialog.
 *  dflt    - Default name of file.
 *  ext     - Default extension to be added to files without extensions.
 *  initdir - directory in which to open the browser (NULL = current dir)
 *  filter  - Filter for matched files to choose from.
 *  Has a format like this:
 *  "C Files (*.c)\0*.c\0"
 *  "All Files\0*.*\0\0"
 *  If these two strings were concatenated, then a choice of two file
 *  filters will be selectable to the user.  Then only matching files will
 *  be shown in the browser.  If NULL, the default allows all files.
 *
 *  *NOTE* - the filter string must be terminated with TWO nulls.
 */
    char_u *
gui_mch_browse(
    int saving,
    char_u *title,
    char_u *dflt,
    char_u *ext,
    char_u *initdir,
    char_u *filter)
{
    //NSLog(@"gui_mch_browse(saving=%d, title=%s, dflt=%s, ext=%s, initdir=%s,"
    //        " filter=%s", saving, title, dflt, ext, initdir, filter);

    char_u *s = (char_u*)[[MMBackend sharedInstance]
            browseForFileInDirectory:(char*)initdir title:(char*)title
                              saving:saving];

    return s;
}
#endif /* FEAT_BROWSE */



    int
gui_mch_dialog(
    int		type,
    char_u	*title,
    char_u	*message,
    char_u	*buttons,
    int		dfltbutton,
    char_u	*textfield)
{
    //NSLog(@"gui_mch_dialog(type=%d title=%s message=%s buttons=%s "
    //        "dfltbutton=%d textfield=%s)", type, title, message, buttons,
    //        dfltbutton, textfield);

    return [[MMBackend sharedInstance] presentDialogWithType:type
                                                       title:(char*)title
                                                     message:(char*)message
                                                     buttons:(char*)buttons
                                                   textField:(char*)textfield];
}


    void
gui_mch_flash(int msec)
{
}


/*
 * Return the Pixel value (color) for the given color name.  This routine was
 * pretty much taken from example code in the Silicon Graphics OSF/Motif
 * Programmer's Guide.
 * Return INVALCOLOR when failed.
 */
    guicolor_T
gui_mch_get_color(char_u *name)
{
    NSString *key = [NSString stringWithUTF8String:(char*)name];
    return [[MMBackend sharedInstance] lookupColorWithKey:key];
}


/*
 * Return the RGB value of a pixel as long.
 */
    long_u
gui_mch_get_rgb(guicolor_T pixel)
{
    // This is only implemented so that vim can guess the correct value for
    // 'background' (which otherwise defaults to 'dark'); it is not used for
    // anything else (as far as I know).
    // The implementation is simple since colors are stored in an int as
    // "rrggbb".
    return pixel;
}


/*
 * Get the screen dimensions.
 * Allow 10 pixels for horizontal borders, 40 for vertical borders.
 * Is there no way to find out how wide the borders really are?
 * TODO: Add live udate of those value on suspend/resume.
 */
    void
gui_mch_get_screen_dimensions(int *screen_w, int *screen_h)
{
    //NSLog(@"gui_mch_get_screen_dimensions()");
    *screen_w = Columns;
    *screen_h = Rows;
}


/*
 * Get the position of the top left corner of the window.
 */
    int
gui_mch_get_winpos(int *x, int *y)
{
    *x = *y = 0;
    return OK;
}


/*
 * Return OK if the key with the termcap name "name" is supported.
 */
    int
gui_mch_haskey(char_u *name)
{
    NSString *value = [NSString stringWithUTF8String:(char*)name];
    if (value)
        return [[MMBackend sharedInstance] hasSpecialKeyWithValue:value];

    return NO;
}


/*
 * Iconify the GUI window.
 */
    void
gui_mch_iconify(void)
{
}


/*
 * Invert a rectangle from row r, column c, for nr rows and nc columns.
 */
    void
gui_mch_invert_rectangle(int r, int c, int nr, int nc)
{
}


#if defined(FEAT_EVAL) || defined(PROTO)
/*
 * Bring the Vim window to the foreground.
 */
    void
gui_mch_set_foreground(void)
{
    [[MMBackend sharedInstance] activate];
}
#endif



    void
gui_mch_set_shellsize(
    int		width,
    int		height,
    int		min_width,
    int		min_height,
    int		base_width,
    int		base_height,
    int		direction)
{
    //NSLog(@"gui_mch_set_shellsize(width=%d, height=%d, min_width=%d,"
    //        " min_height=%d, base_width=%d, base_height=%d, direction=%d)",
    //        width, height, min_width, min_height, base_width, base_height,
    //        direction);
    [[MMBackend sharedInstance] setRows:height columns:width];
}


    void
gui_mch_set_text_area_pos(int x, int y, int w, int h)
{
}

/*
 * Set the position of the top left corner of the window to the given
 * coordinates.
 */
    void
gui_mch_set_winpos(int x, int y)
{
}


#ifdef FEAT_TITLE
/*
 * Set the window title and icon.
 * (The icon is not taken care of).
 */
    void
gui_mch_settitle(char_u *title, char_u *icon)
{
    //NSLog(@"gui_mch_settitle(title=%s, icon=%s)", title, icon);

    [[MMBackend sharedInstance] setVimWindowTitle:(char*)title];
}
#endif


    void
gui_mch_toggle_tearoffs(int enable)
{
}


    static BOOL
gui_macvim_is_valid_action(NSString *action)
{
    static NSDictionary *actionDict = nil;

    if (!actionDict) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *path = [mainBundle pathForResource:@"Actions"
                                              ofType:@"plist"];
        if (path) {
            actionDict = [[NSDictionary alloc] initWithContentsOfFile:path];
        } else {
            // Allocate bogus dictionary so that error only pops up once.
            actionDict = [NSDictionary new];
            EMSG(_("E???: Failed to load action dictionary"));
        }
    }

    return [actionDict objectForKey:action] != nil;
}



// -- Client/Server ---------------------------------------------------------

#ifdef MAC_CLIENTSERVER

//
// NOTE: Client/Server is only fully supported with a GUI.  Theoretically it
// would be possible to make the server code work with terminal Vim, but it
// would require that a run-loop is set up and checked.  This should not be
// difficult to implement, simply call gui_mch_update() at opportune moments
// and it will take care of the run-loop.  Another (bigger) problem with
// supporting servers in terminal mode is that the server listing code talks to
// MacVim (the GUI) to figure out which servers are running.
//


/*
 * Register connection with 'name'.  The actual connection is named something
 * like 'org.vim.MacVim.VIM3', whereas the server is called 'VIM3'.
 */
    void
serverRegisterName(char_u *name)
{
    NSString *svrName = [NSString stringWithUTF8String:(char*)name];
    [[MMBackend sharedInstance] registerServerWithName:svrName];
}


/*
 * Send to an instance of Vim.
 * Returns 0 for OK, negative for an error.
 */
    int
serverSendToVim(char_u *name, char_u *cmd, char_u **result,
        int *port, int asExpr, int silent)
{
    BOOL ok = [[MMBackend sharedInstance]
            sendToServer:[NSString stringWithUTF8String:(char*)name]
                  string:[NSString stringWithUTF8String:(char*)cmd]
                   reply:result
                    port:port
              expression:asExpr
                  silent:silent];

    return ok ? 0 : -1;
}


/*
 * Ask MacVim for the names of all Vim servers.
 */
    char_u *
serverGetVimNames(void)
{
    char_u *names = NULL;
    NSArray *list = [[MMBackend sharedInstance] serverList];

    if (list) {
        NSString *string = [list componentsJoinedByString:@"\n"];
        names = vim_strsave((char_u*)[string UTF8String]);
    }

    return names;
}


/*
 * 'str' is a hex int representing the send port of the connection.
 */
    int
serverStrToPort(char_u *str)
{
    int port = 0;

    sscanf((char *)str, "0x%x", &port);
    if (!port)
        EMSG2(_("E573: Invalid server id used: %s"), str);

    return port;
}


/*
 * Check for replies from server with send port 'port'.
 * Return TRUE and a non-malloc'ed string if there is.  Else return FALSE.
 */
    int
serverPeekReply(int port, char_u **str)
{
    NSString *reply = [[MMBackend sharedInstance] peekForReplyOnPort:port];
    if (str)
        *str = (char_u*)[reply UTF8String];

    return reply != nil;
}


/*
 * Wait for replies from server with send port 'port'.
 * Return 0 and the malloc'ed string when a reply is available.
 * Return -1 on error.
 */
    int
serverReadReply(int port, char_u **str)
{
    NSString *reply = [[MMBackend sharedInstance] waitForReplyOnPort:port];
    if (reply && str) {
        *str = vim_strsave((char_u*)[reply UTF8String]);
        return 0;
    }

    return -1;
}


/*
 * Send a reply string (notification) to client with port given by "serverid".
 * Return -1 if the window is invalid.
 */
    int
serverSendReply(char_u *serverid, char_u *reply)
{
    int retval = -1;
    int port = serverStrToPort(serverid);
    if (port > 0 && reply) {
        BOOL ok = [[MMBackend sharedInstance]
                sendReply:[NSString stringWithUTF8String:(char*)reply]
                   toPort:port];
        retval = ok ? 0 : -1;
    }

    return retval;
}

#endif // MAC_CLIENTSERVER
