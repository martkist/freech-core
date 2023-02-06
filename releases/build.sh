MAKEOPTS=${MAKEOPTS:--j3}
DOCKEROPTS="--build-arg TAG=$FREECH_TAG --build-arg MAKEOPTS=$MAKEOPTS"

echo "Building Linux release..."
docker build -t freech:release-linux-$FREECH_TAG -f release-linux.Dockerfile . $DOCKEROPTS
container_id=$(docker create "freech:release-linux-$FREECH_TAG")
docker cp "$container_id:/outputs/" "outputs/"
docker rm "$container_id"

# echo "Building Windows release..."
# docker build -t freech:release-windows-$FREECH_TAG -f release-windows.Dockerfile . $DOCKEROPTS
# container_id=$(docker create "freech:release-windows-$FREECH_TAG")
# docker cp "$container_id:/outputs/" "outputs/"
# docker rm "$container_id"

# echo "Building macOS release..."
# docker build -t freech:release-macos-$FREECH_TAG -f release-macos.Dockerfile . $DOCKEROPTS
# container_id=$(docker create "freech:release-macos-$FREECH_TAG")
# docker cp "$container_id:/outputs/" "outputs/"
# docker rm "$container_id"

echo "Done!"