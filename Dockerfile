# ======== Stage 1: Build the application ========
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

# ======== Stage 2: Run the application ========
FROM openjdk:17-slim
WORKDIR /app
COPY --from=build /app/target/career-paths-0.0.1-SNAPSHOT.jar app.jar
CMD ["java", "-jar", "app.jar"]
