# build-profile.sh

A script to build a [Drupal](https://drupal.org/) site from *make* files with all the custom code.


## Usage

`build-profile.sh SOURCE_DIR [DESTINATION_DIR]`

Builds Drupal installation using *make* scripts found in `SOURCE_DIR` directory.

*Make* scripts in the `SOURCE_DIR` directory should be named:

* either `drupal-org.make` and `drupal-org-core.make` (standard [*make* files for Drush](https://drupal.org/node/1476014)),
* or `profile.make` and `profile-core.make` (as used for example by [Commerce Platform](https://marketplace.commerceguys.com/platform)).

Also, `SOURCE_DIR` should include all [required install profile files](https://drupal.org/node/1022020).

If no `DESTINATION_DIR` is specified, the new site will be built in `./www` directory.


## Examples

Clone *2.x* branch of Drupal [Commerce Kickstart](https://drupal.org/project/commerce_kickstart) installation profile and build it in `/var/www/` directory.

```shell
git clone --branch 7.x-2.x http://git.drupal.org/project/commerce_kickstart.git
./build-profile.sh commerce_kickstart /var/www
```
