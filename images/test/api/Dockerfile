FROM python:3.7.4
ARG USER_ID
ARG GROUP_ID
ARG BUILD_PROFILE
COPY judo-lanus /services/judo-lanus
COPY dependencies /services/dependencies
COPY assets/test/vassal /services/vassal
COPY supervisor-conf/$BUILD_PROFILE /services/supervisor-conf/
RUN pip install --upgrade pip \
    && pip install -r /services/dependencies/requirements.txt
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /services/
RUN useradd -u $USER_ID -g $GROUP_ID judo-lanus-api -d /services && chown -R judo-lanus-api /services
USER judo-lanus-api
WORKDIR /services/judo-lanus
CMD ./entrypoint.sh