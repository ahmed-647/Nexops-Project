FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
# Root path
COPY nexops-app-dockerfiles/app-source/pom.xml .
RUN mvn dependency:go-offline -B
COPY nexops-app-dockerfiles/app-source/src ./src
RUN mvn package -DskipTests

FROM eclipse-temurin:17-jre-alpine
RUN addgroup -S nexopsgroup && adduser -S nexopsuser -G nexopsgroup
WORKDIR /opt/nexops
COPY --from=builder /app/target/*.jar ./nexops-core-app.jar
USER nexopsuser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "nexops-core-app.jar"]
