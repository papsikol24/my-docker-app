# Multi-stage build for Python dependencies
FROM python:3.9-slim AS api-builder

WORKDIR /app
COPY api/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY api/ .

# Final image with both Nginx and Python
FROM nginx:alpine

# Install Python and supervisord
RUN apk add --no-cache \
    python3 \
    py3-pip \
    supervisor \
    && ln -sf python3 /usr/bin/python

# Copy Python application
COPY --from=api-builder /app /app/api

# Copy nginx configuration and static files
COPY nginx/conf/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/html /usr/share/nginx/html

# Install Python dependencies in final image
RUN pip3 install --no-cache-dir -r /app/api/requirements.txt

# Create supervisor configuration
RUN echo '[supervisord]' > /etc/supervisord.conf && \
    echo 'nodaemon=true' >> /etc/supervisord.conf && \
    echo 'logfile=/dev/null' >> /etc/supervisord.conf && \
    echo 'pidfile=/run/supervisord.pid' >> /etc/supervisord.conf && \
    echo '' >> /etc/supervisord.conf && \
    echo '[program:nginx]' >> /etc/supervisord.conf && \
    echo 'command=nginx -g "daemon off;"' >> /etc/supervisord.conf && \
    echo 'autostart=true' >> /etc/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisord.conf && \
    echo 'stdout_logfile=/dev/stdout' >> /etc/supervisord.conf && \
    echo 'stdout_logfile_maxbytes=0' >> /etc/supervisord.conf && \
    echo 'stderr_logfile=/dev/stderr' >> /etc/supervisord.conf && \
    echo 'stderr_logfile_maxbytes=0' >> /etc/supervisord.conf && \
    echo '' >> /etc/supervisord.conf && \
    echo '[program:api]' >> /etc/supervisord.conf && \
    echo 'command=python3 /app/api/app.py' >> /etc/supervisord.conf && \
    echo 'directory=/app/api' >> /etc/supervisord.conf && \
    echo 'autostart=true' >> /etc/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisord.conf && \
    echo 'stdout_logfile=/dev/stdout' >> /etc/supervisord.conf && \
    echo 'stdout_logfile_maxbytes=0' >> /etc/supervisord.conf && \
    echo 'stderr_logfile=/dev/stderr' >> /etc/supervisord.conf && \
    echo 'stderr_logfile_maxbytes=0' >> /etc/supervisord.conf

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisord.conf"]