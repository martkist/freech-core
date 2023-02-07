MAKEOPTS=${MAKEOPTS:--j3}
DOCKEROPTS="--build-arg TAG=$FREECH_TAG --build-arg MAKEOPTS=$MAKEOPTS"

echo "Building Linux release..."
docker build $DOCKEROPTS -t freech:release-linux-$FREECH_TAG -f release-linux.Dockerfile . 
container_id=$(docker create "freech:release-linux-$FREECH_TAG")
docker cp "$container_id:/outputs" .
docker rm "$container_id"

echo "Building Windows release..."
docker build $DOCKEROPTS -t freech:release-win-$FREECH_TAG -f release-win.Dockerfile .
container_id=$(docker create "freech:release-win-$FREECH_TAG")
docker cp "$container_id:/outputs/" .
docker rm "$container_id"

echo "Building macOS release..."
docker build $DOCKEROPTS -t freech:release-macos-$FREECH_TAG -f release-macos.Dockerfile .
container_id=$(docker create "freech:release-macos-$FREECH_TAG")
docker cp "$container_id:/outputs/" .
docker rm "$container_id"

echo "Done!"