# Build stage
FROM maven:3.9.6-eclipse-temurin-21-jammy AS builder
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Run stage
FROM eclipse-temurin:21-jre-jammy-minimal
WORKDIR /app

# Create non-root user
RUN addgroup --system javauser && adduser --system --group javauser
USER javauser

# Copy jar from build stage
COPY --from=builder /build/target/*.jar app.jar

# Configure JVM options
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Run application
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar app.jar" ]