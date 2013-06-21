ln-semver-git-wrapper
=====================

A bash git wrapper written for the www.liveninja.com dev team which automagically updates git tags with proper semver version tracking

- place .bash_profile directly in your user directory ( e.g. /Users/username/.bash_profile )
- if .bash_profile already exists, simply append the contents of this file to the end of your existing one.
- you must have git installed
- currently only updates version when pushing to a branch named "dev"
- this has only been tested on mac osx 10.8
