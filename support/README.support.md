Support scripts for maintenance of Sympa package
================================================

### correct_msgid

Corrects texts to be translated in source code according to changes in en_US
translation catalog (en_US.po).
Typically used in `sync_translation.sh` below.

### git-set-file-times

Sets mtime and atime of files to the latest commit time in git.

Initially taken from repository of rsync
https://git.samba.org/?p=rsync.git;a=history;f=support/git-set-file-times
at 2009-01-13, and made modifications.

### make_crawlers.pl

Generates `Sympa/WWW/Crawlers.pm` file, by running as:
```
make_crawlers.pl -o $MODULEDIR/Sympa/WWW/Crawlers.pm
```

### pod2md

Converts POD data to Markdown format.  This may be used as a replacement of
pod2man(1).  To generate Markdown texts of all available PODs, run:
```
make POD2MAN="POD2MDOUTPUT=directory pod2md"
```
then, generated texts will be saved in _directory_.

### sync_translation.sh

This runs on the translation server so that it synchronizes between Pootle
store and Git repository.  Requirements:

  - Pootle is installed with virtualenv onto `~pootle/env`.
  - GitHub Access Token is setup.

Then run (replace `$POOTLE_TRANSLATION_DIRECTORY` with the value in
`pootle.conf`):
```
git clone --depth 50 \
    git@github.com-sympa-community-sympa:sympa-community/sympa.git
cd sympa
support/sync_translation.sh $POOTLE_TRANSLATION_DIRECTORY
```

Updates of translations are pushed into `translation` branch in the Git
repository.  Updates of translation templates in the source (`*.pot`) are
applied into Pootle store.

### xgettext.pl

The xgettext(1) utility specific to Sympa. Typically invoked by automated
processes updating translation catalog.

How to prepare a new source tarball
===================================

Notes:

  * In below, the username associated with the Git commits should be
    "`Sympa authors <devel@sympa.community>`".

  * Currently, `sync_translation.sh` described above creates the commits
    for steps 3 and 4 automatically and pushes them to `translation`
    branch on the repository.

  1. Checkout main branch.
     ```
     $ git checkout main
     ```

  2. Tidy all sources.
     ```
     $ make tidyall
     ```

     Then commit the changes.

  3. Retrieve latest translations from translate.sympa.community.  Then
     merge it into the source, for example:
     ```
     $ cd (top)/po/sympa
     $ msgcat -o LL.ponew --use-first UPDATED/LL.po LL.po
     $ mv LL.ponew LL.po
     ```

     And optionally, if en_US.po has been updated, update messages in the
     sources according to it.
     ```
     $ cd (top)
     $ support/correct_msgid --domain=sympa
     $ support/correct_msgid --domain=web_help
     ```

     Then commit the changes.

  4. Update translation catalog.
     ```
     $ cd (top)/po/sympa; make clean sympa.pot-update update-po
     $ cd (top)/po/web_help; make clean web_help.pot-update update-po
     ```

     Then commit the changes.

  5. Prepare the new version on the repository.

     Update configure.ac (update version number) and NEWS.md.

     Then commit the changes with message "[-release] Preparing version x.x.x".

  6. Push all of the commits described in above into remote repository.

  7. Cleanup everything.
     ```
     $ cd (top)
     $ make distclean
     $ rm -Rf autom4te.cache/
     ```

     And sync with repository.
     ```
     $ git pull
     $ support/git-set-file-times
     ```

  8. Configure, create and check distribution.
     ```
     $ autoreconf -i
     $ ./configure --enable-fhs --with-confdir=/etc/sympa
     $ make distcheck
     ```

     If something went wrong, fix it, return to 6 above and try again.

  9. Upload generated files to release section:

       - sympa-VERSION.tar.gz
       - sympa-VERSION.tar.gz.md5
       - sympa-VERSION.tar.gz.sha256
       - sympa-VERSION.tar.gz.sha512
 
  10. Tag the remote repository with the new version number.
