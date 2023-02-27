# Creating release builds

To create release builds, tag the release, push to GitHub, and then execute build with `FREECH_TAG` specified:

````
FREECH_TAG=v0.9.36
git tag $FREECH_TAG
git push --tags
./build.sh
````