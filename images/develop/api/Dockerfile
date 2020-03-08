FROM python:3.7.4
ARG USER_ID
ARG GROUP_ID
ARG BUILD_PROFILE
COPY vero /services/vero
COPY dependencies /services/dependencies
COPY supervisor-conf/$BUILD_PROFILE /services/supervisor-conf/
RUN pip install --upgrade pip \
    && pip install -r /services/dependencies/requirements.txt
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /services/
RUN useradd -u $USER_ID -g $GROUP_ID vero-api -d /services && chown -R vero-api /services
USER vero-api