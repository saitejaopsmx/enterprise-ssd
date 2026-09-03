/*
--------------------------------------------------------------------------------
 * Generic Session Management Script for OWASP ZAP
 *
 * Feature Highlights:
 *   1. JSONPath Token Extraction: Configurable via script parameters (default: $.AuthenticationResult.AccessToken).
 *   2. Smart JSON-Marshalled Detection: Automatically detects and unmarshals double-serialized/stringified JSON.
 *   3. Custom Header Injection: Configurable target header and prefix (default: Authorization: Bearer <token>).
 *   4. Context-Scoped Memory: Uses session.setValue / session.getValue for ZAP ScriptBasedSession.
 * -------------------------------------------------------------------------------- */

function getValueByJsonPath(jsonObj, jsonPath) {
    if (!jsonObj || !jsonPath) return null;
    // Remove leading '$' or '.'
    var cleanPath = jsonPath.replace(/^\$\./, "").replace(/^\$/, "");
    if (cleanPath.trim().length === 0) return jsonObj;
    var parts = cleanPath.split('.');
    var currentNode = jsonObj;
    for (var i = 0; i < parts.length; i++) {
        if (currentNode == null || currentNode == undefined) {
            return null;
        }
        // Auto-detect and unmarshal stringified JSON fields
        if (typeof currentNode === "string") {
            var trimmedStr = currentNode.trim();
            if (trimmedStr.charAt(0) === '{' || trimmedStr.charAt(0) === '[') {
                try {
                    currentNode = JSON.parse(trimmedStr);
                } catch (e) {
                    // String was not valid JSON, proceed with raw string
                }
            }
        }
        // Check for array indexing syntax, e.g. "items[0]" or "token[0]"
        var arrayMatch = parts[i].match(/^(\w+)\[(\d+)\]$/);
        if (arrayMatch) {
            var key = arrayMatch[1];
            var index = parseInt(arrayMatch[2], 10);
            var objVal = currentNode[key];
            // If the array field itself is stringified JSON, unmarshal it
            if (typeof objVal === "string") {
                var t = objVal.trim();
                if (t.charAt(0) === '{' || t.charAt(0) === '[') {
                    try {
                        objVal = JSON.parse(t);
                    } catch (e2) {}
                }
            }
            if (Array.isArray(objVal) && index < objVal.length) {
                currentNode = objVal[index];
            } else {
                return null;
            }
        } else {
            currentNode = currentNode[parts[i]];
        }
    }
    // Final check: If the extracted leaf node is still stringified JSON, unmarshal it
    if (typeof currentNode === "string") {
        var finalTrim = currentNode.trim();
        if (finalTrim.charAt(0) === '{' || finalTrim.charAt(0) === '[') {
            try {
                var parsedFinal = JSON.parse(finalTrim);
                return parsedFinal;
            } catch (e3) {}
        }
    }
    return currentNode;
}

/**
 * Called by ZAP when extracting session tokens from authenticated messages.
 */
function extractWebSession(sessionWrapper) {
    print("[SessionScript] extractWebSession invoked by ZAP");
    var msg = sessionWrapper.getHttpMessage();
    if (!msg) return;
    var responseBody = msg.getResponseBody().toString();
    if (!responseBody || responseBody.trim().length === 0) {
        return;
    }
    // Get raw parameter and sanitize if concatenated incorrectly
    var rawPath = sessionWrapper.getParam("Token_JSONPath") || "response.token[0].accessToken";
    var tokenPath = rawPath.split("Target_Header=")[0].split("&")[0].trim();
    try {
        var jsonResp = JSON.parse(responseBody);
        var extractedToken = getValueByJsonPath(jsonResp, tokenPath);
        if (extractedToken != null && extractedToken != undefined) {
            var tokenStr = String(extractedToken).trim();
            var session = sessionWrapper.getSession();
            // ZAP's ScriptBasedSession uses setValue / getValue
            session.setValue("AUTH_TOKEN", tokenStr);
            print("[SessionScript] Successfully extracted and stored AUTH_TOKEN: " +
                  (tokenStr.length > 25 ? tokenStr.substring(0, 25) + "..." : tokenStr));
        } else {
            print("[SessionScript] Token NOT found at JSONPath: " + tokenPath);
        }
    } catch (err) {
        print("[SessionScript] Error parsing response body JSON: " + err);
    }
}

/**
 * Called by ZAP before sending every request in this Context to attach the session token.
 */
function processMessageToMatchSession(sessionWrapper) {
    var msg = sessionWrapper.getHttpMessage();
    var session = sessionWrapper.getSession();
    // ZAP's ScriptBasedSession uses setValue / getValue
    var token = session.getValue("AUTH_TOKEN");
    var rawHeader = sessionWrapper.getParam("Target_Header") || "Authorization";
    var targetHeader = rawHeader.split("Token_Prefix=")[0].split("&")[0].trim();
    if (!targetHeader) targetHeader = "Authorization";
    var tokenPrefix = sessionWrapper.getParam("Token_Prefix");
    if (tokenPrefix == null || tokenPrefix == undefined || tokenPrefix.trim().length === 0) {
        tokenPrefix = "Bearer ";
    }
    if (token && String(token).trim().length > 0) {
        msg.getRequestHeader().setHeader(targetHeader, tokenPrefix + String(token));
    }
}

/**
 * Called by ZAP when clearing or resetting session state.
 */
function clearWebSessionIdentifiers(sessionWrapper) {
    print("[SessionScript] Clearing session identifiers");
    var session = sessionWrapper.getSession();
    session.setValue("AUTH_TOKEN", null);
}

/**
 * Defines the required script parameters for ZAP API / GUI configuration.
 */
function getRequiredParamsNames() {
    return ["Token_JSONPath"];
}

/**
 * Defines the optional script parameters.
 */
function getOptionalParamsNames() {
    return ["Target_Header", "Token_Prefix"];
}
