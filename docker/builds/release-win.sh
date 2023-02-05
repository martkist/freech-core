echo "Building Windows release..."
docker build -t freech:release-win -f release-win.Dockerfile . --build-arg makeopts=-j3

echo "Packaging..."
rm -rf "outputs/win"
container_id=$(docker create "freech:release-win")
docker cp "$container_id:/outputs/" "outputs/win/"
docker rm "$container_id"
