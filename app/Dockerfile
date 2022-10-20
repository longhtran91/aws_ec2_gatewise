FROM python:3.10-slim-buster

WORKDIR /gatewise-docker

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

CMD ["uvicorn", "app:app", "--proxy-headers", "--host=0.0.0.0", "--forwarded-allow-ips=*"]