# ---------- Stage 1: Build the app with Maven ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom first to leverage Docker layer caching for dependencies
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Copy source and build
COPY src ./src
RUN mvn -B clean package -DskipTests=false

# ---------- Stage 2: Lightweight runtime image ----------
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy only the built jar from the build stage
COPY --from=build /app/target/devops-cicd-lab.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
