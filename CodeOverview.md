_Note that this document is quite out of date, check the README file that comes with the source code (inside the `src/MacVim` folder) for more up to date information._

MacVim consists of two major parts: MacVim.app and Vim.  Vim is the actual text editor and contains no GUI (as in AppKit) related code. MacVim.app is the GUI which coordinates one or more Vim processes at the same time. Code shared between MacVim and Vim goes in `MacVim.[h|m]`.

**Vim**:
  * Vim calls `gui_mch_*` etc. are in `gui_macvim.m`, these mostly passes calls on to `MMBackend`.
  * `MMBackend`: singleton, acts as proxy for the frontend (`MMVimController`), implements `MMBackendProtocol`

**MacVim**:
  * `MMAppController`: singleton, delegate of `NSApp`, manages the app, listens for incoming connections from Vim on a named connection, the `MMAppController` object is vended by this connection, maintains list of `MMVimControllers`, implements `MMAppProtocol`
  * `MMVimController`: manages one Vim process, handles everything not directly relating to views, manages main menu, owns `MMWindowController`, should in theory be able to run without a window, acts as proxy object for the backend (`MMBackend`), implements `MMFrontendProtocol`
  * `MMWindowController`: derives from `NSWindowController`, handles everything view related, owns `MMTextStorage`/`MMTextView`
  * `MainMenu.nib`: instantiates `MMAppController` and makes it the delegate of `NSApp`, the menus in this nib are ignored, menus are set up in `$VIM/gvimrc` and in `$VIMRUNTIME/menu.vim`


MacVim and Vim communicate via distributed objects. The protocols used can be found in `MacVim.h`.  Here are some points to note (in no particular order):
  * Messages are queued and should not be sent whilst processing a DO message.
  * Input from MacVim to Vim that change state should go through `processInput:data:` in `MMBackendProtocol`.
  * State query messages can be sent synchronously, just add the appropriate message in `MMBackendProtocol`.
  * Output from Vim to MacVim arrives in `processCommandQueue:` in `MMFrontendProtocol`.
  * Take care not to call `processInput:data:` too often or the app might stall.  Instead use sendMessage:data: in MMVimController to pass input to Vim, which will drop a message if it cannot be delivered immediately.  This should not pose a problem since Vim should hold the actual state and MacVim should only mirror it.  Sometimes this is not the case, e.g. when dragging to resize the window.  In such situations sendMessageNow:data:timeout: can be used instead (but only very sparingly and with extreme caution).