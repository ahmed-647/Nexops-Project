package com.nexops;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@SpringBootApplication
@RestController
public class NexopsApplication {

    public static void main(String[] args) {
        SpringApplication.run(NexopsApplication.class, args);
    }

    // Advanced Telemetry Payload Mock for Phase 5 AIOps Scaling Core
    @GetMapping("/api/v1/status")
    public Map<String, Object> getSystemStatus() {
        Map<String, Object> metrics = new HashMap<>();
        metrics.setStatus("HEALTHY");
        metrics.setEngine("NEXOPS-AI-NATIVE");
        metrics.setDeploymentType("Multi-Stage-Docker");
        metrics.setClusterNode("K3s-Mumbai-Cloud");
        return metrics;
    }
}