// This authentication script can be used to authenticate in a webapplication via forms.
// The submit target for the form, the name of the username field, the name of the password field
// and, optionally, any extra POST Data fields need to be specified after loading the script.
// The username and the password need to be configured when creating any Users
// The authenticate function is called whenever ZAP requires to authenticate, for a Context for which this script
// was selected as the Authentication Method. The function should send any messages that are required to do the authentication
// and should return a message with an authenticated response so the calling method.

// Parameters:
// helper - a helper class providing useful methods: prepareMessage(), sendAndReceive(msg)
// paramsValues - the values of the parameters configured in the Session Properties -> Authentication panel.
// credentials - an object containing the credentials values, as configured in the Session Properties -> Users panel
function authenticate(helper, paramsValues, credentials) {
  print("Authenticating via JavaScript script...");
  var HttpRequestHeader = Java.type("org.parosproxy.paros.network.HttpRequestHeader")
  var HttpHeader = Java.type("org.parosproxy.paros.network.HttpHeader")
  var URI = Java.type("org.apache.commons.httpclient.URI"
  var requestUri = new URI(paramsValues.get("Target_URL"), false);
  var requestMethod = HttpRequestHeader.POST;
  var extraPostData = paramsValues.get("Extra_POST_data");
  var requestBody = paramsValues.get("Username_field") + "=" + encodeURIComponent(credentials.getParam("Username"));
  requestBody+= "&" + paramsValues.get("Password_field") + "=" + encodeURIComponent(credentials.getParam("Password"));
  print("into the script")
  if(extraPostData != null && extraPostData.trim().length() > 0)
    requestBody += "&" + extraPostData.trim()
  var msg = helper.prepareMessage();
  msg.setRequestHeader(new HttpRequestHeader(requestMethod, requestUri, HttpHeader.HTTP10));
  msg.setRequestBody(requestBody);
  msg.getRequestHeader().setContentLength(msg.getRequestBody().length())
  helper.sendAndReceive(msg);
  print("Received response status code: " + msg.getResponseHeader().getStatusCode())
  return msg;

function getRequiredParamsNames(){
  return ["Target_URL", "Username_field", "Password_field"];

function getOptionalParamsNames(){
  return ["Extra POST data"];

function getCredentialsParamsNames(){
  return ["Username", "Password"];
}
