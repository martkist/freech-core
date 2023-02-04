echo "Building Windows release..."
docker build -t freech:release-win -f release-win.Dockerfile . --build-arg makeopts=-j3