FROM python:3.8-slim

WORKDIR /usr/src/app

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get -y install --no-install-recommends build-essential gcc

ADD requirements.txt ./

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

CMD ["python3"]
