FROM ubuntu:latest

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata

RUN apt-get install -y ruby2.5 libruby2.5 ruby2.5-dev bundler \
                     libmagickwand-dev libxml2-dev libxslt1-dev nodejs \
                     apache2 apache2-dev build-essential git-core phantomjs \
                     libsasl2-dev \
                     imagemagick libffi-dev libgd-dev libarchive-dev libbz2-dev		

RUN git clone --depth=1 https://github.com/openstreetmap/openstreetmap-website.git

RUN apt-get remove -y bundler

RUN export LANGUAGE=en_US.UTF-8 export LANG=en_US.UTF-8 export LC_ALL=en_US.UTF-8 && \
    gem2.5 install rdoc && \
    gem2.5 rdoc --all --overwrite
	
RUN gem2.5 install bundler && gem2.5 pristine bundler

RUN gem2.5 install nokogiri -v '1.10.7' && \
	 gem2.5 install nio4r -v '2.5.2' && \
	 gem2.5 install websocket-driver -v '0.7.1' && \
	 gem2.5 install html_tokenizer -v '0.0.7' && \
	 gem2.5 install debug_inspector -v '0.0.3' && \
	 gem2.5 install binding_of_caller -v '0.8.0' && \
	 gem2.5 install msgpack -v '1.3.1' && \
	 gem2.5 install bootsnap -v '1.4.5' && \
	 gem2.5 install ffi -v '1.11.3' && \
	 gem2.5 install sassc -v '2.2.1' && \
	 gem2.5 install json -v '2.3.0' && \
	 gem2.5 install jaro_winkler -v '1.5.4' && \
	 gem2.5 install kgio -v '2.11.2' && \
	 gem2.5 install libxml-ruby -v '3.1.0'  && \	 
	 gem2.5 install nokogumbo -v '2.0.2'  && \
	 gem2.5 install pg -v '1.2.1' && \
	 gem2.5 install puma -v '3.12.2' && \
	 gem2.5 install quad_tile -v '1.0.1' && \
	 gem2.5 install rinku -v '2.0.6' 

RUN cd openstreetmap-website && bundle install 

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN sudo apt-get update && sudo apt-get install yarn
RUN cd openstreetmap-website && bundle exec rake yarn:install

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
RUN brew install pngcrush &&  \
       brew install optipng  && \
       brew install  advpng  &&  \  
       brew install optipng  &&  \
       brew install pngquant &&  \ 
       brew install  jhead  &&  \ 
       brew install  jpegoptim  &&  \ 
       brew install  jpegtran  &&  \
       brew install  gifsicle &&  \ 
       brew install  svgo

RUN apt-get clean

CMD ["bash"]
