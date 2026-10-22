package com.example.demo.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.CallableStatementCallback;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Repository
public class StoredProcedureRepository {

	private final JdbcTemplate jdbcTemplate;

	public StoredProcedureRepository(JdbcTemplate jdbcTemplate) {
		this.jdbcTemplate = jdbcTemplate;
	}

	public List<Map<String, Object>> getMostPopularPriests() {
		return jdbcTemplate.execute(
				"{CALL raport_top10_preoti(?)}",
				(CallableStatementCallback<List<Map<String, Object>>>) cs -> {
					cs.registerOutParameter(1, Types.REF_CURSOR);
					cs.execute();
					try (ResultSet rs = (ResultSet) cs.getObject(1)) {
						List<Map<String, Object>> results = new ArrayList<>();
						while (rs.next()) {
							results.add(Map.of(
									"Biserica", rs.getString("Biserica"),
									"Nume", rs.getString("Nume"),
									"Prenume", rs.getString("Prenume"),
									"NumarEnoriasi", rs.getInt("NumarEnoriasi"),
									"SumaTotalaDonata", rs.getDouble("SumaTotalaDonata")
							));
						}
						return results;
					}
				}
		);
	}

	public List<Map<String, Object>> getLargestDonationsInEventfulMonth() {
		return jdbcTemplate.execute(
				"{CALL raport_biserica_cu_cele_mai_mari_donatii_din_luna_cu_cele_mai_multe_evenimente(?)}",
				(CallableStatementCallback<List<Map<String, Object>>>) cs -> {
					cs.registerOutParameter(1, Types.REF_CURSOR);
					cs.execute();
					try (ResultSet rs = (ResultSet) cs.getObject(1)) {
						List<Map<String, Object>> results = new ArrayList<>();
						while (rs.next()) {
							results.add(Map.of(
									"Biserica", rs.getString("Biserica"),
									"Luna", rs.getString("Luna"),
									"An", rs.getString("An"),
									"SumaTotala", rs.getDouble("SumaTotala"),
									"NumarDonatii", rs.getInt("NumarDonatii")
							));
						}
						return results;
					}
				}
		);
	}

	public List<Map<String, Object>> getLargestSalesInEventfulMonth() {
		return jdbcTemplate.execute(
				"{CALL raport_biserica_cu_cele_mai_mari_vanzari_din_luna_cu_cele_mai_multe_evenimente(?)}",
				(CallableStatementCallback<List<Map<String, Object>>>) cs -> {
					cs.registerOutParameter(1, Types.REF_CURSOR);
					cs.execute();
					try (ResultSet rs = (ResultSet) cs.getObject(1)) {
						List<Map<String, Object>> results = new ArrayList<>();
						while (rs.next()) {
							results.add(Map.of(
									"Biserica", rs.getString("Biserica"),
									"Luna", rs.getString("Luna"),
									"An", rs.getString("An"),
									"SumaTotala", rs.getDouble("SumaTotala"),
									"NumarVanzari", rs.getInt("NumarVanzari")
							));
						}
						return results;
					}
				}
		);
	}
}
