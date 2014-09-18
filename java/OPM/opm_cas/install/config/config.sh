#!/bin/bash
function exit_on_error()
{
    echo Config Error Find!
    exit 1
}

trap exit_on_error ERR 

source opm_cas.config


cat > deployerConfigContext.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!--
    | deployerConfigContext.xml centralizes into one file some of the declarative configuration that
    | all CAS deployers will need to modify.
    |
    | This file declares some of the Spring-managed JavaBeans that make up a CAS deployment.  
    | The beans declared in this file are instantiated at context initialization time by the Spring 
    | ContextLoaderListener declared in web.xml.  It finds this file because this
    | file is among those declared in the context parameter "contextConfigLocation".
    |
    | By far the most common change you will need to make in this file is to change the last bean
    | declaration to replace the default SimpleTestUsernamePasswordAuthenticationHandler with
    | one implementing your approach for authenticating usernames and passwords.
    +-->

<!--
  ~ Licensed to Jasig under one or more contributor license
  ~ agreements. See the NOTICE file distributed with this work
  ~ for additional information regarding copyright ownership.
  ~ Jasig licenses this file to you under the Apache License,
  ~ Version 2.0 (the "License"); you may not use this file
  ~ except in compliance with the License.  You may obtain a
  ~ copy of the License at the following location:
  ~
  ~   http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing,
  ~ software distributed under the License is distributed on an
  ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  ~ KIND, either express or implied.  See the License for the
  ~ specific language governing permissions and limitations
  ~ under the License.
  -->

<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:sec="http://www.springframework.org/schema/security"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.1.xsd
       http://www.springframework.org/schema/security http://www.springframework.org/schema/security/spring-security-3.1.xsd">
    <!--
        | This bean declares our AuthenticationManager.  The CentralAuthenticationService service bean
        | declared in applicationContext.xml picks up this AuthenticationManager by reference to its id, 
        | "authenticationManager".  Most deployers will be able to use the default AuthenticationManager
        | implementation and so do not need to change the class of this bean.  We include the whole
        | AuthenticationManager here in the userConfigContext.xml so that you can see the things you will
        | need to change in context.
        +-->
    <bean id="authenticationManager"
        class="org.jasig.cas.authentication.AuthenticationManagerImpl">
        
        <!-- Uncomment the metadata populator to allow clearpass to capture and cache the password
             This switch effectively will turn on clearpass.
        <property name="authenticationMetaDataPopulators">
           <list>
              <bean class="org.jasig.cas.extension.clearpass.CacheCredentialsMetaDataPopulator">
                 <constructor-arg index="0" ref="credentialsCache" />
              </bean>
           </list>
        </property>
         -->
        
        <!--
            | This is the List of CredentialToPrincipalResolvers that identify what Principal is trying to authenticate.
            | The AuthenticationManagerImpl considers them in order, finding a CredentialToPrincipalResolver which 
            | supports the presented credentials.
            |
            | AuthenticationManagerImpl uses these resolvers for two purposes.  First, it uses them to identify the Principal
            | attempting to authenticate to CAS /login .  In the default configuration, it is the DefaultCredentialsToPrincipalResolver
            | that fills this role.  If you are using some other kind of credentials than UsernamePasswordCredentials, you will need to replace
            | DefaultCredentialsToPrincipalResolver with a CredentialsToPrincipalResolver that supports the credentials you are
            | using.
            |
            | Second, AuthenticationManagerImpl uses these resolvers to identify a service requesting a proxy granting ticket. 
            | In the default configuration, it is the HttpBasedServiceCredentialsToPrincipalResolver that serves this purpose. 
            | You will need to change this list if you are identifying services by something more or other than their callback URL.
            +-->
        <property name="credentialsToPrincipalResolvers">
            <list>
                <!--
                    | UsernamePasswordCredentialsToPrincipalResolver supports the UsernamePasswordCredentials that we use for /login 
                    | by default and produces SimplePrincipal instances conveying the username from the credentials.
                    | 
                    | If you've changed your LoginFormAction to use credentials other than UsernamePasswordCredentials then you will also
                    | need to change this bean declaration (or add additional declarations) to declare a CredentialsToPrincipalResolver that supports the
                    | Credentials you are using.
                    +-->
                <bean
                    class="org.jasig.cas.authentication.principal.UsernamePasswordCredentialsToPrincipalResolver" />
                <!--
                    | HttpBasedServiceCredentialsToPrincipalResolver supports HttpBasedCredentials.  It supports the CAS 2.0 approach of
                    | authenticating services by SSL callback, extracting the callback URL from the Credentials and representing it as a
                    | SimpleService identified by that callback URL.
                    |
                    | If you are representing services by something more or other than an HTTPS URL whereat they are able to
                    | receive a proxy callback, you will need to change this bean declaration (or add additional declarations).
                    +-->
                <bean
                    class="org.jasig.cas.authentication.principal.HttpBasedServiceCredentialsToPrincipalResolver" />
            </list>
        </property>

        <!--
            | Whereas CredentialsToPrincipalResolvers identify who it is some Credentials might authenticate, 
            | AuthenticationHandlers actually authenticate credentials.  Here we declare the AuthenticationHandlers that
            | authenticate the Principals that the CredentialsToPrincipalResolvers identified.  CAS will try these handlers in turn
            | until it finds one that both supports the Credentials presented and succeeds in authenticating.
            +-->
        <property name="authenticationHandlers">
            <list>
                <!--
                    | This is the authentication handler that authenticates services by means of callback via SSL, thereby validating
                    | a server side SSL certificate.
                    +-->
                <bean class="org.jasig.cas.authentication.handler.support.HttpBasedServiceCredentialsAuthenticationHandler"
                    p:httpClient-ref="httpClient" />
                <!--
                    | This is the authentication handler declaration that every CAS deployer will need to change before deploying CAS 
                    | into production.  The default SimpleTestUsernamePasswordAuthenticationHandler authenticates UsernamePasswordCredentials
                    | where the username equals the password.  You will need to replace this with an AuthenticationHandler that implements your
                    | local authentication strategy.  You might accomplish this by coding a new such handler and declaring
                    | edu.someschool.its.cas.MySpecialHandler here, or you might use one of the handlers provided in the adaptors modules.
                    +-->
                <!-- disable this!!!
                <bean class="org.jasig.cas.authentication.handler.support.SimpleTestUsernamePasswordAuthenticationHandler" />
                -->
                
                <!--
                    | @author hpp
                    | the QueryDatabaseAuthenticationHandler
                    +-->
               <bean class="org.jasig.cas.adaptors.jdbc.QueryDatabaseAuthenticationHandler">
                    <property name="sql" value="select passwd from opmuser where userid=?" />
                    <property name="passwordEncoder" ref="passwordEncoder"/>  
                    <property name="dataSource" ref="dataSource" />
               </bean> 

            </list>
        </property>
    </bean>
    
    <bean id="passwordEncoder" class="org.jasig.cas.authentication.handler.DefaultPasswordEncoder" autowire="byName">
        <constructor-arg value="MD5"/>
    </bean>               
    <!--
        | @author hpp
        | the user data base
        +--> 
    <bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
        <property name="driverClassName"><value>com.mysql.jdbc.Driver</value></property>
        <property name="url"><value>jdbc:mysql://$opm_cas_database</value></property>
        <property name="username"><value>$opm_cas_database_user</value></property>
        <property name="password"><value>$opm_cas_database_pwd</value></property>
    </bean>

    <!--
    This bean defines the security roles for the Services Management application.  Simple deployments can use the in-memory version.
    More robust deployments will want to use another option, such as the Jdbc version.
    
    The name of this should remain "userDetailsService" in order for Spring Security to find it.
     -->
    <!-- <sec:user name="@@THIS SHOULD BE REPLACED@@" password="notused" authorities="ROLE_ADMIN" />-->
    <!--
    <sec:user-service id="userDetailsService">
        <sec:user name="ops" password="123" authorities="ROLE_OPS" /> 
        <sec:user name="@@THIS SHOULD BE REPLACED@@" password="notused" authorities="ROLE_OPS" /> 
     </sec:user-service>
     -->

    <!-- 
        | @author hpp
        | to get the user info for the usage of the spring secutiry after check
        +-->
     <sec:jdbc-user-service id="userDetailsService"
         data-source-ref="dataSource"
         users-by-username-query="select userid, passwd, is_enabled from opmuser where userid = ?"
        authorities-by-username-query="select userid, usergroup from opmuser where userid = ?" />
    
    <!-- 
    Bean that defines the attributes that a service may return.  This example uses the Stub/Mock version.  A real implementation
    may go against a database or LDAP server.  The id should remain "attributeRepository" though.
     -->
    <bean id="attributeRepository"
        class="org.jasig.services.persondir.support.StubPersonAttributeDao">
        <property name="backingMap">
            <map>
                <entry key="uid" value="uid" />
                <entry key="eduPersonAffiliation" value="eduPersonAffiliation" /> 
                <entry key="groupMembership" value="groupMembership" />
            </map>
        </property>
    </bean>
    
    <!-- 
    Sample, in-memory data store for the ServiceRegistry. A real implementation
    would probably want to replace this with the JPA-backed ServiceRegistry DAO
    The name of this bean should remain "serviceRegistryDao".
     -->
    <bean
        id="serviceRegistryDao"
        class="org.jasig.cas.services.InMemoryServiceRegistryDaoImpl">
            <property name="registeredServices">
                <list>
                    <bean class="org.jasig.cas.services.RegexRegisteredService">
                        <property name="id" value="0" />
                        <property name="name" value="HTTP and IMAP" />
                        <property name="description" value="Allows HTTP(S) and IMAP(S) protocols" />
                        <property name="serviceId" value="^(https?|imaps?)://.*" />
                        <property name="evaluationOrder" value="10000001" />
                    </bean>
                    <!--
                    Use the following definition instead of the above to further restrict access
                    to services within your domain (including subdomains).
                    Note that example.com must be replaced with the domain you wish to permit.
                    -->
                    <!--
                    <bean class="org.jasig.cas.services.RegexRegisteredService">
                        <property name="id" value="1" />
                        <property name="name" value="HTTP and IMAP on example.com" />
                        <property name="description" value="Allows HTTP(S) and IMAP(S) protocols on example.com" />
                        <property name="serviceId" value="^(https?|imaps?)://([A-Za-z0-9_-]+\.)*example\.com/.*" />
                        <property name="evaluationOrder" value="0" />
                    </bean>
                    -->
                </list>
            </property>
        </bean>

  <bean id="auditTrailManager" class="com.github.inspektr.audit.support.Slf4jLoggingAuditTrailManager" />
  
  <bean id="healthCheckMonitor" class="org.jasig.cas.monitor.HealthCheckMonitor">
    <property name="monitors">
      <list>
        <bean class="org.jasig.cas.monitor.MemoryMonitor"
            p:freeMemoryWarnThreshold="10" />
        <!--
          NOTE
          The following ticket registries support SessionMonitor:
            * DefaultTicketRegistry
            * JpaTicketRegistry
          Remove this monitor if you use an unsupported registry.
        -->
        <bean class="org.jasig.cas.monitor.SessionMonitor"
            p:ticketRegistry-ref="ticketRegistry"
            p:serviceTicketCountWarnThreshold="5000"
            p:sessionCountWarnThreshold="100000" />
      </list>
    </property>
  </bean>
</beans>

EOF
