DOCKEROPTS=--pull=false --build-arg makeopts=-j3

echo "Building base image..."
docker build -t freech:base -f base.Dockerfile .

echo "Building Windows build environment..."
docker build $DOCKEROPTS -t freech:win-base -f win-base.Dockerfile . 

echo "Building openssl for Windows..."
docker build $DOCKEROPTS -t freech:win-openssl -f win-openssl.Dockerfile .

echo "Building zlib for Windows..."
docker build $DOCKEROPTS -t freech:win-zlib -f win-zlib.Dockerfile .

echo "Building db48 for Windows..."
docker build $DOCKEROPTS -t freech:win-db48 -f win-db48.Dockerfile .

echo "Building boost for Windows..."
docker build $DOCKEROPTS -t freech:win-boost -f win-boost.Dockerfile .

echo "Building freechd for Windows..."
docker build $DOCKEROPTS -t freech:win-freechd -f win-freechd.Dockerfile .

echo "Packaging..."
container_id=$(docker create "freech:win-freechd")
docker cp "$container_id:/root/outputs" .
docker rm "$container_id"
