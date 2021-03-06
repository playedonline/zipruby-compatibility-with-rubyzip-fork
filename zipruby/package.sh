#!/bin/sh
# run this to build the gem
#   use 'release' to copy files before tagging.
#   use 'release_cleanup' to clean up copied files after tagging.
# For a release, because we are not publishing to rubygems/rubyforge, we must commit once with the
# zipruby.c file. Then bundler require in that dependency explicitly. So any ref/tag bundler depends
# on must have zipruby.c and libzip committed.

VERSION='0.3.7'

rm *.gem *.tar.bz2 2>/dev/null
rm -rf doc

if [ "$1" == 'release_cleanup' ]; then
  echo " ** Cleaning up files copied here for release/tagging purposes."
  cd ../libzip
  for f in `ls *.{c,h}`; do
    rm "../zipruby/ext/$f"
  done
  cd ../zipruby
  rm zipruby.c
  rmdir work/
  exit 0
fi

echo "/* rdoc source                                        *" > zipruby.c
echo " * THIS IS AUTOGENERATED in package.sh                *" >> zipruby.c
echo " * Only commit this file if creating a releasable gem */" >> zipruby.c
echo '' >> zipruby.c
for i in ext/*.[ch]
do
  echo $i
  tr -d '\r' < $i > $i.x && mv $i.x $i
done
cat ext/*.c >> zipruby.c
cp ../libzip/*.{c,h} ext

if [ "$1" == 'release' ]; then
  echo "** Exiting after creating zipruby.c, copying libzip. Create your release tag in git, push, then delete zipruby.c and commit/push."
  exit 0
fi


rdoc -w 4 -SHN -m README.txt README.txt zipruby.c LICENSE.libzip ChangeLog --title 'Zip/Ruby-Compat - Ruby bindings for libzip.'
mkdir work
cp -r * work 2> /dev/null
cd work
tar jcf zipruby-${VERSION}.tar.bz2 --exclude=.svn README.txt *.gemspec ext doc
gem build zipruby-compat.gemspec
# Not tested
# gem build zipruby-mswin32.gemspec
# gem build zipruby1.8-mswin32.gemspec
# cp zipruby-${VERSION}-x86-mswin32.gem zipruby-${VERSION}-mswin32.gem
# rm -rf lib
# not tested
# mv lib1.9 lib
# gem build zipruby1.9-mswin32.gemspec
rm zipruby.c
cp *.gem *.tar.bz2 ..
cd ..
for i in `ls ../libzip/*.{c,h}`
do
  rm ext/`basename $i`
done
rm -rf work
