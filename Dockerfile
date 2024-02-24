ARG PYTHON_VERSION=3.11
FROM docker.io/python:${PYTHON_VERSION}-alpine as builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Make use of virtualenv, to cleanly install Python requirements, without
# triggering the ugly "WARNING: Running pip as the 'root' user can result
# in broken permissions and conflicting behaviour".
ENV VIRTUAL_ENV=/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install requirements.
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt

FROM docker.io/python:${PYTHON_VERSION}-alpine

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy virtual environment from the builder stage
COPY --from=builder /venv /venv

# Set the virtual environment as the default Python environment
ENV VIRTUAL_ENV=/venv
ENV PATH="/venv/bin:$PATH"
ENV TZ=Europe/Amsterdam

# Install app
WORKDIR /app
COPY app.py /app

ENV PYTHONPATH /app

# Run app
CMD ["gunicorn", "-w 4", "app:app"]
