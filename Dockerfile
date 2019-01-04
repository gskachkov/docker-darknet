FROM ubuntu:18.04
MAINTAINER gskachkov@gmail.com

ENV APP_DIR /darknet

COPY darknet.sh /
COPY entrypoint1.sh /
COPY nginx.conf /etc/nginx/nginx.conf
COPY app.ini /app.ini

RUN chmod +x darknet.sh \
 && chmod +x entrypoint1.sh

# && apk add --update --no-cache \
#    build-base curl \
#    make \
#    gcc \
#    git \
#    perl \
#    uwsgi-python nginx gfortran py2-pip python-dev \
#    jpeg-dev zlib-dev
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    make \
    git \
    gcc \
    perl \
    libfreetype6-dev \
    libhdf5-serial-dev \
    libpng-dev \
    libzmq3-dev \
    pkg-config \
    python \
    python-dev \
    rsync \
    software-properties-common \
    unzip \
    python-pip \
    python-setuptools \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LIBRARY_PATH=/lib:/usr/lib

RUN curl -o yolov3-laptop_1300.weights -L https://www.dropbox.com/s/n21etx0mvs8jwdq/yolov3-laptop_1300.weights?dl=1

RUN pip2 install --upgrade pip
RUN pip2 install cython
RUN pip2 install numpy
RUN pip2 install Pillow
RUN pip2 install flask
RUN pip2 install flask-jsonpify
RUN pip2 install flask-restful
RUN pip2 install flask_uploads 
RUN rm -rf /var/cache/apk/*


RUN git clone https://github.com/gskachkov/darknet.git && chmod 777 /run/ -R && chmod 777 /root/ -R
RUN (cd /darknet && make && rm -rf scripts src results obj .git) 

COPY entrypoint1.sh /darknet/entrypoint1.sh

RUN curl -o yolov3-laptop_1300.weights -L https://www.dropbox.com/s/n21etx0mvs8jwdq/yolov3-laptop_1300.weights?dl=1
RUN chmod +x yolov3-laptop_1300.weights
RUN ls
RUN ls ./yolov3-laptop_1300.weights
COPY ./yolov3-laptop_1300.weights ./darknet/yolov3-laptop_1300.weights

# RUN rm -rf yolov3-laptop_1300.weights

WORKDIR ${APP_DIR}

EXPOSE 8080

## WORKDIR "/darknet"
ENTRYPOINT ["/entrypoint1.sh"]
CMD ["detector", "test", "cfg/laptop.data", "cfg/yolov3-laptop.cfg", "/yolov3-laptop_1300.weights"]