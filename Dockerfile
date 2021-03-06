FROM soxueren/osm-website:base

ENV PGDATABASE osm
ENV PGPASSWORD 123456
ENV PGUSER postgres
ENV PGHOST localhost
ENV PGPORT 5432

RUN apt-get update 

RUN cd /openstreetmap-website/db/functions && \
        make libpgosm.so && \
        cd ../..
		
RUN apt-get install -y pngcrush optipng pngquant jhead jpegoptim gifsicle

RUN apt-get clean

ADD postgresql/database.yml /openstreetmap-website/config/database.yml

RUN touch /openstreetmap-website/config/settings.local.yml
	
RUN cp /openstreetmap-website/config/example.storage.yml /openstreetmap-website/config/storage.yml

WORKDIR /openstreetmap-website

EXPOSE 3000

CMD ["bundle", "exec", "rails" ,"server", "-b" ,"0.0.0.0"]
