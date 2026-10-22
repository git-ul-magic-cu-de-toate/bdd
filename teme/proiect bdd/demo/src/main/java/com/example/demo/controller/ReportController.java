package com.example.demo.controller;

import com.example.demo.service.ReportService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/most-popular-priests")
    public List<Map<String, Object>> getMostPopularPriests() {
        List<Map<String, Object>> results = reportService.fetchMostPopularPriests();
        return results.stream().map(result -> {
            Map<String, Object> orderedResult = new LinkedHashMap<>();
            orderedResult.put("Biserica", result.get("Biserica"));
            orderedResult.put("Nume", result.get("Nume"));
            orderedResult.put("Prenume", result.get("Prenume"));
            orderedResult.put("NumarEnoriasi", result.get("NumarEnoriasi"));
            orderedResult.put("SumaTotalaDonata", result.get("SumaTotalaDonata"));
            return orderedResult;
        }).collect(Collectors.toList());
    }

    @GetMapping("/largest-donations")
    public List<Map<String, Object>> getLargestDonationsInEventfulMonth() {
        List<Map<String, Object>> results = reportService.fetchLargestDonationsInEventfulMonth();
        return results.stream().map(result -> {
            Map<String, Object> orderedResult = new LinkedHashMap<>();
            orderedResult.put("Luna", result.get("Luna"));
            orderedResult.put("An", result.get("An"));
            orderedResult.put("Biserica", result.get("Biserica"));
            orderedResult.put("SumaTotala", result.get("SumaTotala"));
            orderedResult.put("NumarDonatii", result.get("NumarDonatii"));
            return orderedResult;
        }).collect(Collectors.toList());
    }

    @GetMapping("/largest-sales")
    public List<Map<String, Object>> getLargestSalesInEventfulMonth() {
        List<Map<String, Object>> results = reportService.fetchLargestSalesInEventfulMonth();
        return results.stream().map(result -> {
            Map<String, Object> orderedResult = new LinkedHashMap<>();
            orderedResult.put("Luna", result.get("Luna"));
            orderedResult.put("An", result.get("An"));
            orderedResult.put("Biserica", result.get("Biserica"));
            orderedResult.put("SumaTotala", result.get("SumaTotala"));
            orderedResult.put("NumarVanzari", result.get("NumarVanzari"));
            return orderedResult;
        }).collect(Collectors.toList());
    }
}
