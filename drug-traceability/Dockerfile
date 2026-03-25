# 药品追溯系统后端 - 多阶段构建
FROM maven:3.8-eclipse-temurin-8-alpine AS builder
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn package -DskipTests -B

# 运行阶段
FROM eclipse-temurin:8-jre-alpine
WORKDIR /app

RUN apk add --no-cache tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
