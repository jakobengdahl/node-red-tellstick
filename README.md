# node-red-tellstick
Docker image with node-red installed plus tellstick

Start with privileged and access to USB like:
docker run -d -p 1880:1880 --privileged -v /dev/bus/usb:/dev/bus/usb jakobengdahl/node-red-tellstick
