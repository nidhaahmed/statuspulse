FROM python:3.11-alpine AS builder

WORKDIR /app

RUN apk update && apk upgrade && \
    apk add --no-cache \
    gcc \
    musl-dev \
    postgresql-dev \
    libffi-dev \
    && pip install --no-cache-dir --upgrade pip setuptools wheel

COPY app/requirements.txt .

RUN pip install --no-cache-dir \
    --user \
    -r requirements.txt

FROM python:3.11-alpine

WORKDIR /app

RUN apk update && apk upgrade && \
    apk add --no-cache \
    curl \
    postgresql-libs \
    libffi \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup

COPY --from=builder /root/.local /home/appuser/.local

COPY app/ .

RUN chown -R appuser:appgroup /app

ENV PATH="/home/appuser/.local/bin:$PATH"

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
CMD curl -f http://localhost:8000/health || exit 1

CMD ["gunicorn", "-w", "1", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:8000"]