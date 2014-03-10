#!/bin/bash

# -----------------------------------------------
# Build the Drupal site with all the custom code.
# -----------------------------------------------


# Figure out directory real path.
# readlink -f doesn't work on Macs, so this.
function realpath () {
  TARGET_FILE=$1

  cd `dirname $TARGET_FILE`
  TARGET_FILE=`basename $TARGET_FILE`

  while [ -L "$TARGET_FILE" ]
  do
    TARGET_FILE=`readlink $TARGET_FILE`
    cd `dirname $TARGET_FILE`
    TARGET_FILE=`basename $TARGET_FILE`
  done

  PHYS_DIR=`pwd -P`
  RESULT=$PHYS_DIR/$TARGET_FILE
  echo $RESULT
}


# Drush executable.
[[ $DRUSH && ${DRUSH-x} ]] || DRUSH=drush

# Move to the top directory.
# ROOT=$(git rev-parse --show-toplevel)
# cd $ROOT


# Make sure at least one argument was provided.
if [ "$#" -eq 0 ]; then
  echo "Error: Mising source directory name."
  echo "For help, type platform-build.sh -h"
  exit 1
fi

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: platform-build.sh SOURCE_DIR [DESTINATION_DIR]"
  echo "Builds Drupal installation using make scripts found in SOURCE_DIR directory."
  echo "Make scripts should be named profile.make and profile-core.make."
  echo "If no DESTINATION_DIR is specified, the new site will be built in ./www directory."
  exit
fi


echo "Checking environment..."

# Verify that source directory exists.
if [ ! -d "$1" ]; then
  echo "Error: source directory $1 does not exists"
  exit 2
fi
SRCDIR=$(realpath $1)

# Verify that project.make file exists in the source directory.
if [ ! -f "$SRCDIR/project.make" ]; then
  echo "Error: $SRCDIR/project.make file is missing"
  exit 3
fi

# Verify that project-core.make file exists in the source directory.
if [ ! -f "$SRCDIR/project-core.make" ]; then
  echo "Error: $SRCDIR/project-core.make file is missing"
  exit 4
fi

# Get the installation profile name from the source directory
# (it might be different from the source directory name).
if [ -f $SRCDIR/$SRCDIR.info ]; then
  PROFILE=$SRCDIR
else
  # Check if there is exactly one .info file in the source directory.
  COUNT=`ls -1 $SRCDIR/*.info 2>/dev/null | wc -l`
  if [ $COUNT == 1 ]; then
    # Get the core file name to be used as installation profile name.
    PROFILE=$(ls $SRCDIR/*.info)
    PROFILE=${PROFILE%%.*}
    PROFILE=${PROFILE##*/}
    echo "$PROFILE installation profile found in $SRCDIR directory."
  else
    echo "Error: could not find an installation profile in $SRCDIR directory."
    exit 5
  fi
fi


# Get destination directory.
if [ $2 ]; then
  DESTDIR="$2"
else
  DESTDIR="www"
fi
# Convert it to the absolute path.
DESTDIR=$(realpath $DESTDIR)


# Build the profile using drush.
(
  echo "Downloading contrib modules/themes/libraries..."

  cd $SRCDIR

  # Download the contrib modules/themes/libraries (see: https://drupal.org/comment/8310967#comment-8310967)
  $DRUSH make --no-core --contrib-destination="." project.make .

  cd ..
)


# Build Drupal core and move the profile to the correct place.
(
  # Backup the sites/default directory if it exists.
  chmod -R +w $DESTDIR/sites/* || true
  if [ -d $DESTDIR/sites/default ]; then
    echo "Backing up sites/default directory to $SRCDIR/sites-backup..."
    mv $DESTDIR/sites/default $SRCDIR/sites-backup
  else
    mkdir -p $DESTDIR/sites/default
  fi
  rm -Rf $DESTDIR || true

  # Build Drupal core.
  echo "Building Drupal core..."
  $DRUSH make $SRCDIR/project-core.make $DESTDIR

  # Restore the sites directory.
  if [ -d $SRCDIR/sites-backup ]; then
    echo "Restoring sites/default directory..."
    rm -Rf $DESTDIR/sites/default
    mv $SRCDIR/sites-backup/ $DESTDIR/sites/default
  fi


  # Move the profile in place.
  cd $DESTDIR/profiles
  ln -s $SRCDIR $PROFILE

  echo "Created symbolic link $DESTDIR/profiles/$PROFILE -> $SRCDIR."
  echo
  echo "Site successfully built in $DESTDIR directory."
)
