#!/bin/bash
set -xe

# -----------------------------------------------
# Build the Drupal site with all the custom code.
# -----------------------------------------------

# Drush executable.
[[ $DRUSH && ${DRUSH-x} ]] || DRUSH=drush

# Move to the top directory.
# ROOT=$(git rev-parse --show-toplevel)
# cd $ROOT


# Build the profile using drush.
(
  cd bpost_eshop

  # Download the contrib modules/themes/libraries (see: https://drupal.org/comment/8310967#comment-8310967)
  $DRUSH make --no-core --contrib-destination="." project.make .
  
  cd ..
)


# Build Drupal core and move the profile to the correct place.
(
  # Backup the sites/default directory if it exists.
  if [ -d www/sites/default ]; then
    mv www/sites/default sites-backup
  else
    mkdir -p www/sites/default
  fi
  chmod +w www/sites/* || true
  rm -Rf www || true

  # Build Drupal core.
  $DRUSH make bpost_eshop/project-core.make www

  # Restore the sites directory.
  if [ -d sites-backup ]; then
    rm -Rf www/sites/default
    mv sites-backup/ www/sites/default
  fi


  # Move the profile in place.
  cd www/profiles
  ln -s ../../bpost_eshop bpost_eshop
)
