package com.example.drug;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.mybatis.spring.annotation.MapperScan;

@SpringBootApplication
@MapperScan("com.example.drug.mapper")
public class DrugTraceabilityApplication {

    public static void main(String[] args) {
        SpringApplication.run(DrugTraceabilityApplication.class, args);
    }

}