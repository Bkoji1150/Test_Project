# Pull base image 
From tomcat:8 

MAINTAINER "kojibello058@gmail.com" 
EXPOSE 8000
COPY ./webapp/target/webapp.* /usr/local/tomcat/webapps
