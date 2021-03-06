package cn.vobile.opm.dbsync.dao;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class OpmUserDAO {

	@Resource
	private JdbcTemplate jdbcTemplate;
	private static final String UPDATESQL = "UPDATE opmuser SET passwd = ?, is_enabled = ?, "
			+ "usergroup = ?, username = ?, phone = ?, note = ? where userid = ?";
	private static final String INSERTSQL = "INSERT INTO opmuser(userid, "
			+ "passwd, is_enabled, usergroup, username, phone, note) "
			+ "VALUES(?, ?, ?, ?, ?, ?, ?)";
	private static final String COUNTUSER = "SELECT COUNT(id) FROM opmuser";
	private static final String SELECTUSERID = "SELECT userid FROM opmuser";

	public void updateOpmuser(String userid, String passwd, int is_enabled,
			String usergroup, String username, String phone, String note) {
		Object[] params = new Object[] { passwd, is_enabled, usergroup,
				username, phone, note, userid };
		jdbcTemplate.update(UPDATESQL, params);
	}

	public void insertOpmuser(String userid, String passwd, int is_enabled,
			String usergroup, String username, String phone, String note) {
		Object[] params = new Object[] { userid, passwd, is_enabled, usergroup,
				username, phone, note };
		jdbcTemplate.update(INSERTSQL, params);
	}

	public List<String> selectAllUsersId() {
		return jdbcTemplate.queryForList(SELECTUSERID, String.class);
	}

	public int selectCountUser() {
		return jdbcTemplate.queryForObject(COUNTUSER, null, Integer.class);
	}
}
