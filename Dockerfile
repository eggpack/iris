FROM python:3.8-buster as builder

WORKDIR /srv/iris
RUN apt-get update && apt-get -y dist-upgrade \
    && apt-get -y install python-pip uwsgi virtualenv sudo python-dev libyaml-dev \
    libsasl2-dev libldap2-dev nginx uwsgi-plugin-python \
    && rm -rf /var/cache/apt/archives/*
RUN pip install --upgrade pip
RUN pip install pipenv

ADD Pipfile Pipfile.lock .

RUN pipenv lock -r | tee requirements.txt 
RUN pip install -r requirements.txt --prefix /srv/iris
RUN pip install six --prefix /srv/iris

FROM python:3.8-buster

WORKDIR /srv/iris

COPY --from=builder /srv/iris/lib /srv/iris/lib
COPY src /srv/iris/
RUN pip install six certifi --prefix /srv/iris

EXPOSE 16649

ENV PYTHONPATH=/srv/iris:/srv/iris/lib/python3.8/site-packages

CMD [ "python", "iris/bin/run_server.py", "/srv/iris/config.yaml"]
