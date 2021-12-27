FROM ubuntu:16.04

RUN apt-get update -y && \
    apt-get install -y python-pip python-dev

COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip install -r requirements.txt

COPY . /app
RUN apt-get install python-flask -y
ENTRYPOINT [ "python" ]

EXPOSE 5000
CMD [ "app.py" ]