#First stage
FROM ubuntu:latest as first

#Create content
RUN mkdir /web/
COPY index.php /web/index.php

#Second stage
FROM php:8.3-apache

#Set env
ENV VERSION=v1.0.0

#Copy content
COPY --from=first /web/index.php /var/www/html/

EXPOSE 80

USER www-data 