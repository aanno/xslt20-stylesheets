#!/bin/bash
set -e # Exit with nonzero exit code if anything fails
set -x # Show me what's going on
here=$(dirname "${BASH_SOURCE[0]}")
# Only commits to master should trigger deployment
# (add 'travis' for testing purposes.)

set | grep TRAVIS

VERSION=`grep "^version=" < gradle.properties | cut -f2 -d=`

pwd
whoami

#if [ "$TRAVIS_PULL_REQUEST" != "false" ] || \
if [ "$TRAVIS_BRANCH" != master -a \
     "$TRAVIS_BRANCH" != travis ]; then
    echo "Skipping deployment"
    exit 0
fi

# Remember the SHA of the current build.
SHA=$(git rev-parse --verify HEAD)

# Clone the minimum of the CDN repo needed.
CDN_REPO="https://$GH_TOKEN@github.com/docbook/cdn.git"
git clone $CDN_REPO cdn --depth=1 -q
# Clean out existing content...
rm -rf cdn/release/xsl20/$VERSION
# ...and copy the new one.
mkdir -p cdn/release/xsl20/$VERSION
rm -f cdn/release/xsl20/index.html
cp -a build/distributions/docbook-xslt2-$VERSION.zip cdn/release/xsl20/$VERSION
cd cdn/release/xsl20/$VERSION && unzip docbook-xslt2-$VERSION.zip
# We could normally make "current" symbolic links to "snapshot"
# but github's policy doesn't allow to publish symbolic links in pages.
mkdir -p cdn/release/xsl20/current
rm -rf cdn/release/xsl20/current/*
cp -a cdn/release/xsl20/$VERSION cdn/release/xsl20/current

$here/generate_index.py cdn/release/xsl20

## Now prepare to commit and push to the CDN
#cd cdn
#git config user.name "Travis CI"
#git config user.email "travis-ci"
#
#git add .
#git commit -m "Deploy XSL Stylesheets to GitHub Pages: ${SHA}"
#git push -q origin HEAD
