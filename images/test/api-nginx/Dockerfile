FROM nginx:1.17.2
ARG USER_ID
ARG GROUP_ID
COPY assets/test/api-nginx/nginx.conf /etc/nginx/nginx.conf
COPY assets/test/api-nginx/proxy_params /etc/nginx/proxy_params
COPY assets/test/api-nginx/uwsgi_params /etc/nginx/uwsgi_params
COPY assets/test/api-nginx/judo-lanus.conf /etc/nginx/conf.d/default.conf
RUN useradd -u $USER_ID -g $GROUP_ID vero-api -d /vero
