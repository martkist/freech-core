echo "Building base image..."
docker build -t freech:depends -f depends.Dockerfile .