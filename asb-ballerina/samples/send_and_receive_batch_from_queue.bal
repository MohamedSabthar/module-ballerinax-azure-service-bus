// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/config;
import ballerina/log;
import ballerinax/asb;

public function main() {

    // Input values
    string[] stringArrayContent = ["apple", "mango", "lemon", "orange"];
    map<string> parameters = {contentType: "text/plain", timeToLive: "2"};
    map<string> properties = {a: "propertyValue1", b: "propertyValue2"};
    int maxMessageCount = 3;
    int serverWaitTime = 5;

    asb:ConnectionConfiguration config = {
        connectionString: config:getAsString("CONNECTION_STRING"),
        entityPath: config:getAsString("QUEUE_PATH")
    };

    log:print("Creating Asb sender connection.");
    asb:SenderConnection? senderConnection = checkpanic new (config);

    log:print("Creating Asb receiver connection.");
    asb:ReceiverConnection? receiverConnection = checkpanic new (config);

    if (senderConnection is asb:SenderConnection) {
        log:print("Sending via Asb sender connection.");
        checkpanic senderConnection->sendBatchMessage(stringArrayContent, parameters, properties, maxMessageCount);
    } else {
        log:printError("Asb sender connection creation failed.");
    }

    if (receiverConnection is asb:ReceiverConnection) {
        log:print("Receiving from Asb receiver connection.");
        var messageReceived = receiverConnection->receiveBatchMessage(maxMessageCount);
        if(messageReceived is asb:Messages) {
            int val = messageReceived.getMessageCount();
            log:print("No. of messages received : " + val.toString());
            asb:Message[] messages = messageReceived.getMessages();
            string messageReceived1 =  checkpanic messages[0].getTextContent();
            log:print("Message1 content : " + messageReceived1);
            string messageReceived2 =  checkpanic messages[1].getTextContent();
            log:print("Message2 content : " + messageReceived2);
            string messageReceived3 =  checkpanic messages[2].getTextContent();
            log:print("Message3 content : " + messageReceived3);
        } else {
            log:printError("Receiving message via Asb receiver connection failed.");
        }
    } else {
        log:printError("Asb receiver connection creation failed.");
    }

    if (senderConnection is asb:SenderConnection) {
        log:print("Closing Asb sender connection.");
        checkpanic senderConnection.closeSenderConnection();
    }

    if (receiverConnection is asb:ReceiverConnection) {
        log:print("Closing Asb receiver connection.");
        checkpanic receiverConnection.closeReceiverConnection();
    }
}    
