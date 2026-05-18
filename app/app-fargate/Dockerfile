#First stage
FROM ubuntu:latest AS first

#Create content
RUN mkdir /web/
COPY index.php /web/index.php

#Second stage
FROM php:8.3-apache

#Copy content
COPY --from=first /web/index.php /var/www/html/
COPY .version /etc/app/version

EXPOSE 80

USER www-data
