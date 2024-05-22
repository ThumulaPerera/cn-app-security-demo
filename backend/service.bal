import ballerina/uuid;
import ballerina/http;
// import ballerina/jwt;

type EntryPayload record {|
    string username;
    string value;
|};

type Entry record {|
    string value;
    string id;
|};

map<map<Entry>> entries = {};
// const string DEFAULT_USER = "default";

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: false,
        allowHeaders: ["CORELATION_ID"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}

service / on new http:Listener(9090) {

    resource function get entries(http:Headers headers, string username) returns Entry[]|http:BadRequest|error {
        map<Entry>|http:BadRequest usersEntries = check getUsersEntries(username);
        if (usersEntries is map<Entry>) {
            return usersEntries.toArray();
        }
        return <http:BadRequest>usersEntries;
    }

    resource function post entries(http:Headers headers,
            @http:Payload EntryPayload newEntry) returns http:Created|error {

        string entryId = uuid:createType1AsString();
        map<Entry>|error usersEntries = check getUsersEntries(newEntry.username);
        if (usersEntries is map<Entry>) {
            usersEntries[entryId] = {value: newEntry.value, id: entryId};
            return <http:Created>{};
        }
        return usersEntries;
    }
}

function getUsersEntries(string username) returns map<Entry>|error {
    if (entries[username] is ()) {
        entries[username] = {};
    }
    return <map<Entry>>entries[username];
}

// This function is used to get the diary entries of the user who is logged in.
// User information is extracted from the JWT token.
// function getUsersEntries(http:Headers headers) returns map<Entry>|http:BadRequest|error {
//     string|error jwtAssertion = headers.getHeader("x-jwt-assertion");
//     if (jwtAssertion is error) {
//         http:BadRequest badRequest = {
//             body: {
//                 "error": "Bad Request",
//                 "error_description": "Error while getting the JWT token"
//             }
//         };
//         return badRequest;
//     }

//     [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(jwtAssertion);
//     string username = payload.sub is string ? <string>payload.sub : DEFAULT_USER;
//     if (entries[username] is ()) {
//         entries[username] = {};
//     }
//     return <map<Entry>>entries[username];
// }
