/* --------------------------------------------------------------
 * Generic Authentication script for OWASP ZAP
 * Supports standard Key-Value inputs for JSON & FORM POST Logins.
 * -------------------------------------------------------------- */

function authenticate(helper, paramsValues, credentials) {
    print("[AuthScript] authenticate() invoked by ZAP");

    var HttpRequestHeader = Java.type("org.parosproxy.paros.network.HttpRequestHeader");
    var HttpHeader        = Java.type("org.parosproxy.paros.network.HttpHeader");
    var URI               = Java.type("org.apache.commons.httpclient.URI");

    var type        = paramsValues.get("TYPE"); // JSON or FORM
    var loginUrl    = paramsValues.get("Login_URL");
    var userField   = paramsValues.get("Username_field");
    var passField   = paramsValues.get("Password_field");
    var extraData   = paramsValues.get("Extra_Post_Data");

    var username = credentials.getParam("Username");
    var password = credentials.getParam("Password");

    print("[AuthScript] Config - TYPE: " + type + ", Login_URL: " + loginUrl);
    print("[AuthScript] UserField: " + userField + ", PassField: " + passField + ", User: " + username);

    var requestBody = "";
    var contentType = "";

    if (type === "FORM") {
        requestBody  = userField + "=" + encodeURIComponent(username);
        requestBody += "&" + passField + "=" + encodeURIComponent(password);
        if (extraData && extraData.trim().length > 0) {
            requestBody += "&" + extraData.trim();
        }
        contentType = "application/x-www-form-urlencoded";
    } else if (type === "JSON") {
        var jsonObj = {};
        jsonObj[userField] = username;
        jsonObj[passField] = password;
        if (extraData && extraData.trim().length > 0) {
            try {
                var extraMap = JSON.parse(extraData);
                for (var k in extraMap) { jsonObj[k] = extraMap[k]; }
            } catch(e) {
                print("[AuthScript] [WARN] Extra_Post_Data is not a valid JSON object: " + e);
            }
        }
        requestBody = JSON.stringify(jsonObj);
        contentType = "application/json";
    } else {
        print("[AuthScript] [ERROR] Unsupported TYPE: " + type);
        throw "Unsupported TYPE: " + type;
    }

    print("[AuthScript] Constructed Request Body: " + requestBody);

    var uri = new URI(loginUrl, false);
    var msg = helper.prepareMessage();
    msg.setRequestHeader(new HttpRequestHeader(HttpRequestHeader.POST, uri, HttpHeader.HTTP10));
    msg.setRequestBody(requestBody);
    if (contentType) {
        msg.getRequestHeader().setHeader("Content-Type", contentType);
    }
    msg.getRequestHeader().setContentLength(msg.getRequestBody().length());

    print("[AuthScript] Sending authentication POST request to: " + loginUrl);
    helper.sendAndReceive(msg);

    var statusCode = msg.getResponseHeader().getStatusCode();
    print("[AuthScript] Received Auth Response Code: " + statusCode);
    print("[AuthScript] Response Body Snippet: " + (msg.getResponseBody().toString().substring(0, 100) + "..."));

    return msg;
}


function logout(helper, paramsValues, credentials) {
    print("[AuthScript] logout() invoked by ZAP");
    return null;
}


function getRequiredParamsNames() { return ["Login_URL", "TYPE", "Username_field", "Password_field"]; }

function getOptionalParamsNames() { return ["Extra_Post_Data"]; }

function getCredentialsParamsNames() { return ["Username", "Password"]; }
