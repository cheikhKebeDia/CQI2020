function [gameId] = PracticeMap(api_key, map,  uri)
    gameId = '';
    uri = uri + "/practice";

    contentTypeField = matlab.net.http.field.ContentTypeField('application/json');
    data = struct("map", map);
    body = matlab.net.http.MessageBody(data);

    type = matlab.net.http.MediaType('text/*');
    acceptField = matlab.net.http.field.AcceptField([type]);
    
    xApiKey = matlab.net.http.field.GenericField("X-apikey",api_key);
    
    header = [contentTypeField acceptField xApiKey];
    method = matlab.net.http.RequestMethod.POST;

    request = matlab.net.http.RequestMessage(method,header,body);
    response = send(request,uri);
    
    array = response.Body.Data;
    json = jsondecode(convertCharsToStrings(char(array)));
    gameId = json.uuid;
end



