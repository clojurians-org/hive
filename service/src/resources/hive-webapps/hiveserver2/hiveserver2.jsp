<%--
/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
--%>
<%@ page contentType="text/html;charset=UTF-8"
  import="org.apache.hadoop.conf.Configuration"
  import="org.apache.hive.common.util.HiveVersionInfo"
  import="org.apache.hive.service.cli.operation.Operation"
  import="org.apache.hive.service.cli.operation.SQLOperation"
  import="org.apache.hive.service.cli.session.SessionManager"
  import="org.apache.hive.service.cli.session.HiveSession"
  import="javax.servlet.ServletContext"
  import="java.util.Collection"
  import="java.util.Date"
%>

<%
ServletContext ctx = getServletContext();
Configuration conf = (Configuration)ctx.getAttribute("hive.conf");
long startcode = conf.getLong("startcode", System.currentTimeMillis());
SessionManager sessionManager =
  (SessionManager)ctx.getAttribute("hive.sm");
%>

<!--[if IE]>
<!DOCTYPE html>
<![endif]-->
<?xml version="1.0" encoding="UTF-8" ?>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>HiveServer2</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">

    <link href="/static/css/bootstrap.min.css" rel="stylesheet">
    <link href="/static/css/bootstrap-theme.min.css" rel="stylesheet">
    <link href="/static/css/hive.css" rel="stylesheet">
  </head>

  <body>
  <div class="navbar  navbar-fixed-top navbar-default">
      <div class="container">
          <div class="navbar-header">
              <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                  <span class="icon-bar"></span>
                  <span class="icon-bar"></span>
                  <span class="icon-bar"></span>
              </button>
              <a class="navbar-brand" href="/hiveserver2.jsp"><img src="/static/hive_logo.jpeg" alt="Hive Logo"/></a>
          </div>
          <div class="collapse navbar-collapse">
              <ul class="nav navbar-nav">
                <li class="active"><a href="/">Home</a></li>
                <li><a href="/logs/">Local logs</a></li>
                <li><a href="/jmx">Metrics Dump</a></li>
                <li><a href="/conf">Hive Configuration</a></li>
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

<div class="container">
    <div class="row inner_header">
        <div class="page-header">
            <h1>HiveServer2</h1>
        </div>
    </div>
    <div class="row">

<%
if (sessionManager != null) { 
  long currentTime = System.currentTimeMillis();
%> 

<section>
<h2>Active Sessions</h2>
<table id="attributes_table" class="table table-striped">
    <tr>
        <th>User Name</th>
        <th>IP Address</th>
        <th>Operation Count</th>
        <th>Active Time (s)</th>
        <th>Idle Time (s)</th>
    </tr>
<%
Collection<HiveSession> hiveSessions = sessionManager.getSessions();
for (HiveSession hiveSession: hiveSessions) {
%>
    <tr>
        <td><%= hiveSession.getUserName() %></td>
        <td><%= hiveSession.getIpAddress() %></td>
        <td><%= hiveSession.getOpenOperationCount() %></td>
        <td><%= (currentTime - hiveSession.getCreationTime())/1000 %></td>
        <td><%= (currentTime - hiveSession.getLastAccessTime())/1000 %></td>
    </tr>
<%
}
%>
<tr>
  <td colspan="5">Total number of sessions: <%= hiveSessions.size() %></td>
</tr>
</table>
</section>

<section>
<h2>Queries</h2>
<table id="attributes_table" class="table table-striped">
    <tr>
        <th>User Name</th>
        <th>Query</th>
        <th>State</th>
        <th>Elapsed Time (s)</th>
    </tr>
<%
int queries = 0;
Collection<Operation> operations = sessionManager.getOperations();
for (Operation operation: operations) {
  if (operation instanceof SQLOperation) {
    SQLOperation query = (SQLOperation) operation;
    queries++;
%>
    <tr>
        <td><%= query.getParentSession().getUserName() %></td>
        <td><%= query.getQueryStr() %></td>
        <td><%= query.getStatus().getState() %></td>
        <td><%= (currentTime - query.getLastAccessTime())/1000 %></td>
    </tr>
<%
  }
}
%>
<tr>
  <td colspan="4">Total number of queries: <%= queries %></td>
</tr>
</table>
</section>
<% 
 }
%>

    <section>
    <h2>Software Attributes</h2>
    <table id="attributes_table" class="table table-striped">
        <tr>
            <th>Attribute Name</th>
            <th>Value</th>
            <th>Description</th>
        </tr>
        <tr>
            <td>Hive Version</td>
            <td><%= HiveVersionInfo.getVersion() %>, r<%= HiveVersionInfo.getRevision() %></td>
            <td>Hive version and revision</td>
        </tr>
        <tr>
            <td>Hive Compiled</td>
            <td><%= HiveVersionInfo.getDate() %>, <%= HiveVersionInfo.getUser() %></td>
            <td>When Hive was compiled and by whom</td>
        </tr>
        <tr>
            <td>HiveServer2 Start Time</td>
            <td><%= new Date(startcode) %></td>
            <td>Date stamp of when this HiveServer2 was started</td>
        </tr>
    </table>
    </section>
    </div>
</div>
</body>
</html>