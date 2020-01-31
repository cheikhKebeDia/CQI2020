function [token] = ProductionHandShake(apiKey, uri)
    uri = uri + "/handshake/" + apiKey;

    contentTypeField = matlab.net.http.field.ContentTypeField('application/json');

    type = matlab.net.http.MediaType("application/json");
    acceptField = matlab.net.http.field.AcceptField([type]);

    header = [acceptField contentTypeField];
    method = matlab.net.http.RequestMethod.GET;
    body = [];

    request = matlab.net.http.RequestMessage(method,header,body);
    
    response = send(request,uri);
    decodedResponse = jsondecode(convertCharsToStrings(char(response.Body.Data)));
    token = decodedResponse.token;
end
