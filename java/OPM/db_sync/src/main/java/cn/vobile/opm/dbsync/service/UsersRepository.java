package cn.vobile.opm.dbsync.service;

import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;

import cn.vobile.opm.dbsync.dao.OpmUserDAO;

public class UsersRepository implements Runnable {

	private String host;
	private String port;
	private int timeout;
	@Resource
	private OpmUserDAO opmUserDAO;
	private static final Logger LOGGER = Logger
			.getLogger(UsersRepository.class);

	public void syncUsers() {
		String url = "http://" + host + ":" + port
				+ "/opm_web_shell/GetAllUsersAction.action";
		try {
			HttpURLConnection httpUrlConnection = (HttpURLConnection) new URL(
					url).openConnection();
			httpUrlConnection.setConnectTimeout(1000 * 60 * 10);
			httpUrlConnection.setReadTimeout(1000 * 60 * 10);
			httpUrlConnection.setDoOutput(true);
			httpUrlConnection.setDoInput(true);
			httpUrlConnection.setUseCaches(false);
			httpUrlConnection.setRequestProperty("Content-type",
					"application/x-java-serialized-object");
			httpUrlConnection.setRequestMethod("POST");
			httpUrlConnection.connect();
			OutputStream outStrm = httpUrlConnection.getOutputStream();
			ObjectOutputStream objOutputStrm = new ObjectOutputStream(outStrm);
			objOutputStrm.writeObject(new String("sync"));
			objOutputStrm.flush();
			objOutputStrm.close();
			InputStream inStrm = httpUrlConnection.getInputStream();
			ObjectInputStream objInputStrm = new ObjectInputStream(inStrm);
			String string = (String) objInputStrm.readObject();
			objInputStrm.close();
			JSONArray users = new JSONArray(string);
			List<String> serverList = new ArrayList<String>();
			List<String> clientList = opmUserDAO.selectAllUsersId();
			Map<String, JSONObject> serverMap = new HashMap<String, JSONObject>();
			for (int i = 0; i < users.length(); ++i) {
				serverList.add(users.getJSONObject(i).getString("userid"));
				serverMap.put(users.getJSONObject(i).getString("userid"),
						users.getJSONObject(i));
			}
			serverList.removeAll(clientList);
			for (int i = 0; i < clientList.size(); ++i) {
				JSONObject user = serverMap.get(clientList.get(i));
				if (null != user) {
					opmUserDAO.updateOpmuser(user.getString("userid"),
							user.getString("passwd"),
							user.getInt("is_enabled"),
							user.getString("usergroup"),
							user.getString("username"),
							user.getString("phone"), user.getString("note"));
				}

			}
			for (int i = 0; i < serverList.size(); ++i) {
				JSONObject user = serverMap.get(serverList.get(i));
				opmUserDAO.insertOpmuser(user.getString("userid"),
						user.getString("passwd"), user.getInt("is_enabled"),
						user.getString("usergroup"),
						user.getString("username"), user.getString("phone"),
						user.getString("note"));
			}
		} catch (MalformedURLException e) {
			LOGGER.warn(e.getMessage());
		} catch (IOException e) {
			LOGGER.warn(e.getMessage());
		} catch (ClassNotFoundException e) {
			LOGGER.warn(e.getMessage());
		} catch (Exception e) {
			LOGGER.warn(e.getMessage());
		}
	}

	@Override
	public void run() {
		while (true) {
			syncUsers();
			try {
				Thread.sleep(1000 * 60 * timeout);
			} catch (InterruptedException e) {
				LOGGER.warn(e.getMessage());
			}
		}
	}

	public String getHost() {
		return host;
	}

	public void setHost(String host) {
		this.host = host;
	}

	public String getPort() {
		return port;
	}

	public void setPort(String port) {
		this.port = port;
	}

	public int getTimeout() {
		return timeout;
	}

	public void setTimeout(int timeout) {
		this.timeout = timeout;
	}

}
