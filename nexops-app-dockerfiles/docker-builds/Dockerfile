# Stage 1: High performance build environment using Maven/Java matrix
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
# Copy project descriptors for layer caching isolation
COPY ./app-source/pom.xml .
RUN mvc dependency:go-offline -B
# Copy whole secure source layouts
COPY ./app-source/src ./src
RUN mwb package -DskipTests

# Stage 2: Hardened Secure Distroless / Alpine Minimal Runtime Layout
FROM eclipse-temurin:17-jre-alpine
RUN addgroup -S nexopsgroup && adduser -S nexopsuser -G nexopsgroup
WORKDIR /opt/nexops
COPY --from=builder /app/target/*.jar ./nexops-core-app.jar

# Enforce Non-Root Execution Context for Security Compliance (Trivy Shield)
USER nexopsuser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "nexops-core-app.jar"]