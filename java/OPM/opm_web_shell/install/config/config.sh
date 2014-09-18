#!/bin/bash
function exit_on_error()
{
    echo Config Error Find!
    exit 1
}

trap exit_on_error ERR 

source opm_shell.config


cat > applicationContext.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<beans:beans xmlns="http://www.springframework.org/schema/security"
	xmlns:beans="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:aop="http://www.springframework.org/schema/aop" xmlns:tx="http://www.springframework.org/schema/tx"
	xsi:schemaLocation="
			http://www.springframework.org/schema/beans
			http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
			http://www.springframework.org/schema/tx
			http://www.springframework.org/schema/tx/spring-tx-3.0.xsd
			http://www.springframework.org/schema/aop
			http://www.springframework.org/schema/aop/spring-aop-3.0.xsd
			http://www.springframework.org/schema/security
			http://www.springframework.org/schema/security/spring-security-3.1.xsd">

	<!-- the struts beans -->
	<beans:bean id="AddUserAction"
		class="cn.vobile.opm.web.shell.action.userpage.AddUserAction" scope="prototype">
	</beans:bean>
	<beans:bean id="GetAllOpmUsersAction"
		class="cn.vobile.opm.web.shell.action.userpage.GetAllOpmUsersAction"
		scope="prototype">
	</beans:bean>
	<beans:bean id="GetOpmUserAction"
		class="cn.vobile.opm.web.shell.action.userpage.GetOpmUserAction"
		scope="prototype">
	</beans:bean>
	<beans:bean id="ModifyUserAction"
		class="cn.vobile.opm.web.shell.action.userpage.ModifyUserAction"
		scope="prototype">
	</beans:bean>
	<beans:bean id="ChangePwdAction"
		class="cn.vobile.opm.web.shell.action.userpage.ChangePwdAction" scope="prototype">
	</beans:bean>

	<beans:bean id="GetAllIdcAction"
		class="cn.vobile.opm.web.shell.action.idcpage.GetAllIdcAction" scope="prototype">
	</beans:bean>
	<beans:bean id="AddIdcAction"
		class="cn.vobile.opm.web.shell.action.idcpage.AddIdcAction" scope="prototype">
	</beans:bean>

	<!-- the struts beans -->

	<!-- data source -->
	<beans:bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource"
		destroy-method="close">
		<beans:property name="driverClass" value="com.mysql.jdbc.Driver" />
		<beans:property name="jdbcUrl"
			value="jdbc:mysql://$opm_shell_database?useUnicode=true&amp;characterEncoding=UTF-8" />
		<beans:property name="user" value="$opm_shell_database_user" />
		<beans:property name="password" value="$opm_shell_database_pwd" />

		<!--连接池中保留的最小连接数。 -->
		<beans:property name="minPoolSize">
			<beans:value>$minPoolSize</beans:value>
		</beans:property>

		<!--连接池中保留的最大连接数。Default: 15 -->
		<beans:property name="maxPoolSize">
			<beans:value>$maxPoolSize</beans:value>
		</beans:property>

		<!--初始化时获取的连接数，取值应在minPoolSize与maxPoolSize之间。Default: 3 -->
		<beans:property name="initialPoolSize">
			<beans:value>$initialPoolSize</beans:value>
		</beans:property>

		<!--最大空闲时间,30秒内未使用则连接被丢弃。若为0则永不丢弃。Default: 0 -->
		<beans:property name="maxIdleTime">
			<beans:value>$maxIdleTime</beans:value>
		</beans:property>

		<!--当连接池中的连接耗尽的时候c3p0一次同时获取的连接数。Default: 3 -->
		<beans:property name="acquireIncrement">
			<beans:value>$acquireIncrement</beans:value>
		</beans:property>

		<!--JDBC的标准参数，用以控制数据源内加载的PreparedStatements数量。但由于预缓存的statements 属于单个connection而不是整个连接池。所以设置这个参数需要考虑到多方面的因素。
			如果maxStatements与maxStatementsPerConnection均为0，则缓存被关闭。Default: 0 -->
		<beans:property name="maxStatements">
			<beans:value>$maxStatements</beans:value>
		</beans:property>

		<!--每60秒检查所有连接池中的空闲连接。Default: 0 -->
		<beans:property name="idleConnectionTestPeriod">
			<beans:value>$idleConnectionTestPeriod</beans:value>
		</beans:property>

		<!--定义在从数据库获取新连接失败后重复尝试的次数。Default: 30 -->
		<beans:property name="acquireRetryAttempts">
			<beans:value>$acquireRetryAttempts</beans:value>
		</beans:property>

		<!--获取连接失败将会引起所有等待连接池来获取连接的线程抛出异常。但是数据源仍有效 保留，并在下次调用getConnection()的时候继续尝试获取连接。如果设为true，那么在尝试
			获取连接失败后该数据源将申明已断开并永久关闭。Default: false -->
		<beans:property name="breakAfterAcquireFailure">
			<beans:value>$breakAfterAcquireFailure</beans:value>
		</beans:property>

		<beans:property name="acquireRetryDelay">
			<beans:value>$acquireRetryDelay</beans:value>
		</beans:property>

	</beans:bean>
	<!-- data source -->

	<!-- hibernate3 transaction -->
	<beans:bean id="sessionFactory"
		class="org.springframework.orm.hibernate3.LocalSessionFactoryBean">
		<beans:property name="dataSource">
			<beans:ref bean="dataSource" />
		</beans:property>
		<beans:property name="hibernateProperties">
			<beans:props>
				<beans:prop key="hibernate.dialect">
					org.hibernate.dialect.MySQLDialect
				</beans:prop>
				<beans:prop key="hibernate.connection.useUnicode">true</beans:prop>
				<beans:prop key="hibernate.connection.characterEncoding">UTF-8</beans:prop>
				<beans:prop key="hibernate.connection.charSet">UTF-8</beans:prop>
				<!--
				<beans:prop key="hibernate.show_sql">true</beans:prop>
				<beans:prop key="hibernate.format_sql">true</beans:prop>
				<beans:prop key="hibernate.use_sql_comments">true</beans:prop>
				-->
				<beans:prop key="connection.autocommit">true</beans:prop>


			</beans:props>
		</beans:property>
		<beans:property name="mappingResources">
			<beans:list>
				<beans:value>cn/vobile/opm/web/shell/dao/Opmuser.hbm.xml
				</beans:value>
				<beans:value>cn/vobile/opm/web/shell/dao/Opmidc.hbm.xml
				</beans:value>
			</beans:list>
		</beans:property>
	</beans:bean>



	<tx:annotation-driven transaction-manager="transactionManager"
		proxy-target-class="true" />

	<!-- <beans:bean id="sessionFactory" class="org.springframework.orm.hibernate3.LocalSessionFactoryBean">
		<beans:property name="configLocation" value="classpath:hibernate.cfg.xml">
		</beans:property> </beans:bean> -->

	<beans:bean id="transactionManager"
		class="org.springframework.orm.hibernate3.HibernateTransactionManager">
		<beans:property name="sessionFactory">
			<beans:ref local="sessionFactory" />
		</beans:property>
	</beans:bean>
	<!-- hibernate3 transaction -->

	<!-- spring security -->
	<!-- cas -->
	<beans:bean id="casAuthEntryPoint"
		class="org.springframework.security.cas.web.CasAuthenticationEntryPoint">
		<!-- <beans:property name="loginUrl" value="https://192.168.10.203:8443/cas/"
			/> -->
		<beans:property name="loginUrl" value="$cas_web_local_url" />
		<beans:property name="serviceProperties" ref="casService" />
	</beans:bean>
	<beans:bean id="casService"
		class="org.springframework.security.cas.ServiceProperties">
		<beans:property name="service"
			value="${opm_shell_local_url}j_spring_cas_security_check" />
	</beans:bean>

	<beans:bean id="casAuthenticationFilter"
		class="org.springframework.security.cas.web.CasAuthenticationFilter">
		<beans:property name="authenticationManager" ref="authenticationManager" />
	</beans:bean>

	<beans:bean id="casTicketValidator"
		class="org.jasig.cas.client.validation.Cas20ServiceTicketValidator">
		<!-- <beans:constructor-arg value="https://192.168.10.203:8443/cas/" /> -->
		<beans:constructor-arg value="$cas_web_local_url" />
	</beans:bean>

	<beans:bean id="authenticationUserDetailsService"
		class="org.springframework.security.core.userdetails.UserDetailsByNameServiceWrapper">
		<beans:property name="userDetailsService" ref="jdbcUserService" />
	</beans:bean>

	<jdbc-user-service id="jdbcUserService"
		data-source-ref="dataSource"
		users-by-username-query="select userid, passwd, is_enabled from opmuser where
				userid = ?"
		authorities-by-username-query="select userid, usergroup from
				opmuser where userid = ?" />

	<http pattern="/js/**" security="none" />
	<http pattern="/css/**" security="none" />
	<http pattern="/images/**" security="none" />
	<http pattern="/style/**" security="none" />

	<http pattern="/jsp/common/login.jsp*" security="none" />
	<http auto-config='true' entry-point-ref="casAuthEntryPoint" access-denied-page="/jsp/common/403.jsp">
		<!-- User Viewer -->
		<intercept-url pattern="/index.jsp"
			access="ROLE_VIEWER, ROLE_GS, ROLE_OPS, ROLE_ADMIN" />

		<!-- User GS -->

		<!-- User OPS -->

		<!-- User Admin -->
		<intercept-url pattern="/ModifyUserAction.action"
			access="ROLE_ADMIN" />
		<intercept-url pattern="/AddUserAction.action" access="ROLE_ADMIN" />
		<intercept-url pattern="/ChangeUserPwdAction.action" access="ROLE_ADMIN" />

		<!-- login -->
		<form-login login-page='/jsp/common/login.jsp' />
		<logout logout-url="/j_spring_security_logout"
			logout-success-url="${cas_web_local_url}logout" />
		<custom-filter ref="casAuthenticationFilter" position="CAS_FILTER" />
	</http>

	<authentication-manager alias="authenticationManager">
		<authentication-provider ref="casAuthenticationProvider">
			<!-- <password-encoder hash="md5" /> <jdbc-user-service data-source-ref="dataSource"
				users-by-username-query="select userid, passwd, is_enabled from opmuser where
				userid = ?" authorities-by-username-query="select userid, usergroup from
				opmuser where userid = ?" /> -->
		</authentication-provider>
	</authentication-manager>

	<beans:bean id="casAuthenticationProvider"
		class="org.springframework.security.cas.authentication.CasAuthenticationProvider">
		<beans:property name="ticketValidator" ref="casTicketValidator" />
		<beans:property name="serviceProperties" ref="casService" />
		<beans:property name="key"
			value="an_id_for_this_auth_provider_only" />
		<beans:property name="authenticationUserDetailsService"
			ref="authenticationUserDetailsService" />
	</beans:bean>

	<!-- spring security -->
	<!-- Dao -->
	<beans:bean id="OpmuserDAO" class="cn.vobile.opm.web.shell.dao.OpmuserDAO">
		<beans:property name="sessionFactory">
			<beans:ref bean="sessionFactory" />
		</beans:property>
	</beans:bean>

	<beans:bean id="OpmidcDAO" class="cn.vobile.opm.web.shell.dao.OpmidcDAO">
		<beans:property name="sessionFactory">
			<beans:ref bean="sessionFactory" />
		</beans:property>
	</beans:bean>

</beans:beans>

EOF
