package com.example.demo.service;

import com.example.demo.repository.StoredProcedureRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class ReportService {

    private final StoredProcedureRepository storedProcedureRepository;

    public ReportService(StoredProcedureRepository storedProcedureRepository) {
        this.storedProcedureRepository = storedProcedureRepository;
    }

    public List<Map<String, Object>> fetchMostPopularPriests() {
        return storedProcedureRepository.getMostPopularPriests();
    }

    public List<Map<String, Object>> fetchLargestDonationsInEventfulMonth() {
        return storedProcedureRepository.getLargestDonationsInEventfulMonth();
    }

    public List<Map<String, Object>> fetchLargestSalesInEventfulMonth() {
        return storedProcedureRepository.getLargestSalesInEventfulMonth();
    }
}
