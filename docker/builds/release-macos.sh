echo "Building macOS release..."
docker build -t freech:release-macos -f release-macos.Dockerfile . --build-arg makeopts=-j3

echo "Packaging..."
rm -rf "outputs/macos"
container_id=$(docker create "freech:release-macos")
docker cp "$container_id:/outputs/" "outputs/macos/"
docker rm "$container_id"
