# Contributing #

## First steps ##

First of all, follow the [build instructions](Building.md) on how to get and build the source code.  For simplicity I will assume you have a newly cloned version of the MacVim repository.  Also, when you eventually submit a patch it helps if you have told Git your name and email address because this shows up in the commit history (so that other people may know that you wrote the patch and how to contact you).  To do this, enter something like

```
git config --global user.name "Joe Bloggs"
git config --global user.email "joe.bloggs@gmail.com"
```

(You should obviously put your own name and email address in there.)  This step only needs to be carried out once; the `--global` switch ensures that all Git repositories you have from now on will know your name and email.


## Branching and commiting ##

Lets say you want to add a new feature to MacVim.  The first thing to do is to create a new branch to work on and leave the "master" branch in a pristine condition.  Lets call the new branch "feature":

```
git checkout -b feature
```

This creates a branch called "feature" and checks it out so that you can start working on it.

As you work away on your new feature the daily work flow goes something like:

  1. Edit source code
  1. Build and test
  1. Commit your changes
  1. Repeat

Steps 1-2 are up to you to figure out, step 3 can be done in one of two ways.  The simplest way works if you have only modified existing files:

```
git commit -a
```

This will make a commit including all modified files (but not newly created files!) and bring up an editor window so you can enter a commit message.  Here is an example of what the commit message could look like:

> Don't draw control chars in MMTextStorage

> It can happen that MMTextStorage is asked to draw characters from the
> "Control Characters" set (e.g. when :shell is invoked).  This would
> cause internal errors in MMTextStorage so when control chars are
> detected, simply draw blanks instead.

(Indentation was added only to make the above more readable.)  The format of a commit message is thus: a line with a concise summary of the commit (required), and a blank line followed by a more verbose description of the commit (optional).  To ensure these messages look good, please make sure each line is not longer than 72 characters (hint: add `filetype plugin indent on` to your `.vimrc` and set the environment variable `EDITOR` to `mvim -f`).

If you made a mistake while typing the commit message you can easily change it by entering
```
git commit --amend
```
which will bring up your old commit message so that you may modify it.  (This method not only lets you modify a bad commit message; you can also make modifications to the source code, then type `git commit -a --amend` to rewrite your last commit to include your modifications.)


## Updating to the latest version ##

While you are working on your feature it is not entirely unlikely that commits are made to the public Git repo.  In this situation you will probably want to update your "master" branch to be up-to-date with the public repo.  Before doing this you should make sure you have no uncommited changes (commit first if you do), then you switch to the "master" branch and pull the latest version with two commands:

```
git checkout master
git pull
```

That will update the "master" branch to the latest version of the source code.  In order to get these changes merged into your "feature" branch as well you should rebase your commits on top of the changes made to the "master" branch:

```
git checkout feature
git rebase master
```

Those two commands will switch back to your "feature" branch and then apply the commits you just pulled _in front of_ your own commits that you have made in the "feature" branch.  (Don't worry if this makes no sense to you; check the Git documentation if you are curious as to what `git rebase` does.)


## Submitting a patch ##

When you have finished implementing your new feature you are ready to create a patch series to be submitted.  But before doing so, make sure you have updated your repository to the latest version as described in the previous section.  Once you have updated the "master" branch, you create a patch series with the following command:

```
git format-patch master
```

This will make a diff between your branch and the "master" branch, and output a series of `.patch` files in the current directory.  One patch file is created for each commit that you have made in your branch.

Once you have created the patch files, simply submit them to the [vim\_mac](http://groups.google.com/group/vim_mac) mailing list.  If there are more than one file in the patch series you should archive it first.  For example:

```
tar cjf my-feature.tar.bz2 *.patch
```

This command will create an archive called "my-feature.tar.bz2" containing all the patch files.


## Common tasks ##

The first stop for general Git information is the [Git Home Page](http://git.or.cz/).  I found the [Git Crash Courses](http://git.or.cz/course/) and the [Git User's Manual](http://www.kernel.org/pub/software/scm/git/docs/user-manual.html) very helpful.  However, let me list some of the features I use everyday.

Typically, when I start working I like to see what I am up to:

```
git log
```

Then, I start working and when I'm ready to commit I often review everything I've done so that I may write a decent commit message (and so that I haven't left any NSLog() debugging calls in the source).  First, I check which files I've edited:

```
git status
```

Alternatively, I sometimes like to see the extent of my changes, in which case I use:

```
git diff --status
```

Then, to get a diff of my changes I enter:

```
git diff
```

It often happens that I am simply testing some things out that I don't end up wanting to keep.  To quickly reset all the changes made since the last commit I use:

```
git reset --hard
```

That would undo the changes in all files that are marked as "Changed" in the output of `git status`.  Sometimes all I want to do is to reset all changes in one file, in which case I type:

```
git checkout filename
```

That would undo the changes in the file called "filename" only.

Sometimes I forget which branch I am on (`git status` will also tell you that) or how many branches I have at the moment.  To see a list of my branches:

```
git branch
```


That's all I can think of for the moment.  If you have any questions please post to the [vim\_mac](http://groups.google.com/group/vim_mac) mailing list.  If you have any Git tips or tricks of your own you may want to leave a comment on this page.