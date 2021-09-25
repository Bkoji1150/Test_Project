# Pull base image 
From tomcat:8 

# Maintainer 
MAINTAINER "kojibello058@gmail.com" 
EXPOSE 8080
COPY ./webapp/target/webapp.* /usr/local/tomcat/webapps
