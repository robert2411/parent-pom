FROM maven:3-jdk-11 AS builder

WORKDIR /project
COPY ./pom.xml /project/pom.xml
RUN mvn dependency:resolve
RUN mvn clean install
