function [message] = ProductionMap(token, uri, gamesId, map)
    uri = uri + "/tournaments/rounds/games/"+gamesId+"/map";

    contentTypeField = matlab.net.http.field.ContentTypeField('application/json');
    data = struct("map", map);
    body = matlab.net.http.MessageBody(data);

    type = matlab.net.http.MediaType('text/*');
    acceptField = matlab.net.http.field.AcceptField([type]);
    
    xToken = matlab.net.http.field.GenericField("X-token",token);
    
    header = [contentTypeField acceptField xToken];
    method = matlab.net.http.RequestMethod.POST;

    request = matlab.net.http.RequestMessage(method,header,body);
    response = send(request,uri);
    
    message = convertCharsToStrings(char(response.Body.Data));
end

