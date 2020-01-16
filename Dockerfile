FROM soxueren/osm-website:base

RUN apt-get update 

RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata

RUN apt-get install -y pngcrush optipng pngquant jhead jpegoptim gifsicle

CMD ["bash"]
