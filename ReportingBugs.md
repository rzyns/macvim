Before reporting a bug, make sure you go through the following steps:

### Ensure that configuration files are not the cause ###

Quit MacVim, temporarily rename your rc-files and `.vim` directory, then restart MacVim and see if the problem persists.  If it doesn't then the problem is in some configuration file or a plugin.

(If the problem is in the config files then you can find it by commenting out all lines in the config files and uncommenting one line at a time, restarting MacVim in between to see if the problem reappeared.)

Step-by-step instructions:

1. Open Terminal and type:

```
$ cd ~
$ mv .vimrc old.vimrc
$ mv .gvimrc old.gvimrc
$ mv .vim old.vim
```

(If you don't have one of the files `.vimrc`, `.gvimrc` or the folder `.vim` then the `mv` command will report an error which you can safely ignore.)

2. Restart MacVim and see if the problem persists.

3. To restore your config files, open Terminal and type:

```
$ cd ~
$ mv old.vimrc .vimrc
$ mv old.gvimrc .gvimrc
$ mv old.vim .vim
```


### Test the built-in version of Vim ###

If it is not a problem with the GUI itself, then you can see if the problem also appears in the version of Vim that ships with Mac OS X.  To do so, simply open up Terminal and type `vim` and try to reproduce the problem.  If you _can_ reproduce the problem this way then it is not a bug in MacVim.  Try asking for help on the `vim_use` mailing list.


### Try a newer version of MacVim ###

Download the latest snapshot build of MacVim and see if the problem is still there.


### Ensure that other rc-files are not the cause ###

Quit MacVim, temporarily rename all rc-files for whatever shell you are using (`.profile`, `.bashrc`, etc.), then restart MacVim and see if the problem persists.  Exactly which files to rename depends on which shell you are using.  (To be on the safe side you may want to move all files from your home folder into a temporary folder.)


### Reset the preferences ###

Reset the preferences and restart MacVim.

Step-by-step instructions:

1. Open up Terminal and type (read step 3 first!):

```
$ defaults delete org.vim.MacVim
```

2. Restart MacVim and see if the problem persists (since the prefs were deleted MacVim will ask about auto-updating again).

3. Step 1 cannot be undone, so you'll have to open up the preferences and restore them manually.


### Ask for help ###

If you've tried all the above and the problem still persists, then post to the `vim_mac` mailing list asking for help.  Make sure you state that you have read this page in your post or the first reply will most likely be to read this page!