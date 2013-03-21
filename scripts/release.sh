#! /bin/sh

# Shell script to help automate release of this code to CPAN.
#
# Usage:
#
#   ./release.sh <release-tag> (e.g., ./release.sh 0.03)
#   
# Should be run after all code changes have been made, committed, and
# pushed to github.  

dirs_to_ignore=' ./scripts ./.git '

release=$1

if [ $# -ne 1 ] 
  then
     echo "Usage: $0 <release-tag>"
     exit 1;
fi

echo "Preparing to release $release"

echo "ignoring '$dirs_to_ignore'"

#  * Updates the Version file
echo release-CPAN-$release > VERSION

#  * Updates the MANIFEST (find . -type f | grep -v '\.git' ...)
find . -type f \
| grep -v '\.git' \
| grep -v scripts \
| grep -v .perltidyrc \
| grep -v .gitignore \
| cut -c3-254 > MANIFEST

#  * Removes files and directories that should not be in the release.
#    make distclean

#  * Adds a release tag via 'git tag -a <release-tag>' and pushes it to github
#    (We'll need to set up certificates for SSH/SSL on github...) 
#    git tag -a release-CPAN-$release
#    git push --tags

# Create the tarball for upload to PAUSE
pushd ..
tar -zcf ~/Statistics-RserveClient-$release.tgz  \
--exclude='scripts' \
--exclude='.git' \
--exclude='.gitignore' \
--exclude='.perltidyrc' \
Statistics--RserveClient
popd

# Create README for PAUSE
pod2text lib/Statistics/RserveClient.pm >  ~/Statistics-RserveClient-${release}.readme

