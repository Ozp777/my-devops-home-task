# שלב 1: build / בדיקות
FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
# מריצים טסטים בשלב ה-build
RUN pytest

# שלב 2: image רזה להרצה ב-prod
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000
CMD ["python", "main.py"]

