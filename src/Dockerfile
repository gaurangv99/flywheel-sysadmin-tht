FROM python:3.12 as builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /install /usr/local

COPY . /app

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 5001

CMD ["python", "./app.py"]
