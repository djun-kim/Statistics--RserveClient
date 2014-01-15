#! /bin/sh

# Shell script to help automate release of this code to CPAN.
#
# Usage:
#
#   ./release.sh <release-tag> (e.g., ./release.sh 0.03)
#   
# Should be run after all code changes have been made, committed, and
# pushed to github.  

files_to_ignore=' ./scripts ./.git ./.gitignore ./.perltidyrc'
dotag=0;

usage="Usage: $0 [ --tag ] <release-tag>"

if [ $# -lt 1 ] 
  then
     echo $usage
     exit 1;
fi

arg1=$1;
if [ $arg1 = '--tag' ] 
   then 
     dotag=1;
     release=$2;
     if [ $release ] 
        then
           echo "Release is $release"
     else
        echo $usage;
        exit 1;
     fi
else
     release=$1;
     if [ $release ] 
        then
           echo "Release is $release"
     else
        echo $usage;
        exit 1;
     fi
fi

echo "Preparing to release release-CPAN-$release"
if [ $dotag -eq 1 ] 
   then
      echo "Adding tag release-CPAN-$release to git and pushing."
fi
echo "Ignoring '$files_to_ignore'"

#  * Updates $VERSION strings in all '*.pm' files in lib/Statistics
find lib/Statistics -name '*.pm' -exec scripts/update_version.pl {} $release \;

#  * Updates the Version file
echo release-CPAN-$release > VERSION

#  * Updates the MANIFEST (find . -type f | grep -v '\.git' ...)
find . -type f \
| grep -v '\.git' \
| grep -v scripts \
| grep -v .perltidyrc \
| grep -v .gitignore \
| grep -v Makefile \
| cut -c3-254 > MANIFEST

#  * Removes files and directories that should not be in the release.
perl Makefile.PL
make distclean

# Commit the changes resulting from updating the $VERSION variable and
# push the changes to github.  The push requires git authentication
# via certificates.

git commit -a -m "Updating version number release-CPAN-$release."
git push

#  * Adds a release tag via 'git tag -a <release-tag>' and pushes it to github
#    (We'll need to set up certificates for SSH/SSL on github...) 
if [ $dotag -eq 1 ] 
   then
      git tag -a -m "Release tag for release-CPAN-$release." release-CPAN-$release 
      git push --tags
fi

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

