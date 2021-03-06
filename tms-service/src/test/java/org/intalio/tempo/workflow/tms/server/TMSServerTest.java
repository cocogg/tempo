/**
 * Copyright (c) 2005-2008 Intalio inc.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * Intalio inc. - initial API and implementation
 *
 * $Id: TaskManagementServicesFacade.java 5440 2006-06-09 08:58:15Z imemruk $
 * $Log:$
 */

package org.intalio.tempo.workflow.tms.server;

import java.net.URI;

import junit.framework.Assert;
import junit.framework.TestCase;

import org.intalio.tempo.workflow.task.Notification;
import org.intalio.tempo.workflow.task.PATask;
import org.intalio.tempo.workflow.task.TaskState;
import org.intalio.tempo.workflow.task.xml.XmlTooling;
import org.intalio.tempo.workflow.tms.AccessDeniedException;
import org.intalio.tempo.workflow.tms.UnavailableTaskException;
import org.intalio.tempo.workflow.util.TaskEquality;
import org.w3c.dom.Document;

public class TMSServerTest extends TestCase {

    public static void main(String[] args) {
        junit.textui.TestRunner.run(TMSServerTest.class);
    }

    public void testPATaskLifecycle() throws Exception {
        ITMSServer server = Utils.createTMSServer();

        PATask paTask = new PATask("taskID", new URI("http://localhost/1"), "processID", "urn:completeSOAPAction", Utils.createXMLDocument());
        paTask.getUserOwners().add("test/user1");
        paTask.getRoleOwners().add("test/role3");
        server.create(paTask, "token1");

        TaskEquality.areTasksEquals(paTask, server.getTask("taskID", "token1"));
        TaskEquality.areTasksEquals(paTask, server.getTask("taskID", "token2"));
        TaskEquality.areTasksEquals(paTask, server.getTaskList("token1")[0]);
        TaskEquality.areTasksEquals(paTask, server.getTaskList("token2")[0]);
        try {
            server.getTask("taskID", "token3");
            Assert.fail("AccessDeniedException expected");
        } catch (AccessDeniedException e) {

        }
        Assert.assertEquals(0, server.getTaskList("token3").length);
        
        Document newOutput1 = Utils.createXMLDocument();
        server.setOutput("taskID", newOutput1, "token1");
        PATask taskWithSetOutput = (PATask) server.getTask("taskID", "token2");
        Assert.assertTrue(XmlTooling.equals(newOutput1, taskWithSetOutput.getOutput()));
        Assert.assertEquals(TaskState.READY, taskWithSetOutput.getState());
        
        // test reassign
        org.intalio.tempo.workflow.auth.AuthIdentifierSet newUsers = new org.intalio.tempo.workflow.auth.AuthIdentifierSet(new String[]{"test/user1", "test/user2"});
        org.intalio.tempo.workflow.auth.AuthIdentifierSet newRoles = new org.intalio.tempo.workflow.auth.AuthIdentifierSet(new String[]{"test/role2", "test/role3"});
        server.reassign("taskID", newUsers, newRoles, TaskState.READY, "token1");

        Document newOutput2 = Utils.createXMLDocument();
        server.setOutputAndComplete("taskID", newOutput2, "token2");
        PATask completedTask = (PATask) server.getTask("taskID", "token1");
        Assert.assertTrue(XmlTooling.equals(newOutput2, completedTask.getOutput()));
        Assert.assertEquals(TaskState.COMPLETED, completedTask.getState());

        String failureCode = "failure-code";
        String failureReason = "failure reason";
        server.fail("taskID", failureCode, failureReason, "token1");
        PATask failedTask = (PATask) server.getTask("taskID", "token2");
        Assert.assertEquals(TaskState.FAILED, failedTask.getState());
        Assert.assertEquals(failureCode, failedTask.getFailureCode());
        Assert.assertEquals(failureReason, failedTask.getFailureReason());

        try {
            server.delete(new String[] { "taskID" }, "token1");
            Assert.fail("AuthException expected");
        } catch (UnavailableTaskException e) {

        }

        server.delete(new String[] { "taskID" }, "system-user-token");
        Assert.assertEquals(0, server.getTaskList("token1").length);

        try {
            server.delete(new String[] { "taskID2" }, "system-user-token");
            Assert.fail("Unavailable task expected");
        } catch (UnavailableTaskException e) {

        }

    }

    public void testNotificationLifecycle() throws Exception {
        ITMSServer server = Utils.createTMSServer();
        Notification notification = new Notification("taskID", new URI("http://localhost/1"), Utils.createXMLDocument());
        notification.getUserOwners().add("test/user1");
        notification.getRoleOwners().add("test/role3");
        server.create(notification, "token1");

        TaskEquality.areTasksEquals(notification, server.getTask("taskID", "token1"));
        TaskEquality.areTasksEquals(notification, server.getTask("taskID", "token2"));
        TaskEquality.areTasksEquals(notification, server.getTaskList("token1")[0]);
        TaskEquality.areTasksEquals(notification, server.getTaskList("token2")[0]);
        try {
            server.getTask("taskID", "token3");
            Assert.fail("AccessDeniedException expected");
        } catch (AccessDeniedException e) {

        }
        Assert.assertEquals(0, server.getTaskList("token3").length);

        server.complete("taskID", "token2");
        Notification completedTask = (Notification) server.getTask("taskID", "token1");
        Assert.assertEquals(TaskState.COMPLETED, completedTask.getState());

        String failureCode = "failure-code";
        String failureReason = "failure reason";
        server.fail("taskID", failureCode, failureReason, "token1");
        Notification failedTask = (Notification) server.getTask("taskID", "token2");
        Assert.assertEquals(TaskState.FAILED, failedTask.getState());
        Assert.assertEquals(failureCode, failedTask.getFailureCode());
        Assert.assertEquals(failureReason, failedTask.getFailureReason());

        try {
            server.delete(new String[] { "taskID" }, "token1");
            Assert.fail("AuthException expected");
        } catch (UnavailableTaskException e) {

        }

        server.delete(new String[] { "taskID" }, "system-user-token");
        Assert.assertEquals(0, server.getTaskList("token1").length);
    }
    
//    public void testXX() throws Exception{
//    	 ITMSServer server = Utils.createTMSServer();
//    	 
//        try {
//        	OMElement createTaskRequest = Utils.loadElementFromResource("/createTaskRequest1.xml");
//            OMElementQueue rootQueue = new OMElementQueue(createTaskRequest);
//            String taskID = requireElementValue(rootQueue, "taskId");
//            OMElement omInputContainer = requireElement(rootQueue, "input");
//            Document domInput = null;
//            if (omInputContainer.getFirstElement() != null) {
//                domInput = new TaskUnmarshaller().unmarshalTaskOutput(omInputContainer);
//            }
//            String participantToken = requireElementValue(rootQueue, "participantToken");
//            Document userProcessResponse = _server.initProcess(taskID, domInput, participantToken);
//            if (userProcessResponse == null)
//                throw new RuntimeException("TMP did not return a correct message while calling init");
//            OMElement response = new TMSResponseMarshaller(OM_FACTORY) {
//                public OMElement marshalResponse(Document userProcessResponse) {
//                    OMElement response = createElement("initProcessResponse");
//                    OMElement userProcessResponseWrapper = createElement(response, "userProcessResponse");
//                    userProcessResponseWrapper.addChild(new XmlTooling().convertDOMToOM(userProcessResponse, this.getOMFactory()));
//                    return response;
//                }
//            }.marshalResponse(userProcessResponse);
//            return response;
//        } catch (Exception e) {
//            throw makeFault(e);
//        }
//    }
}
