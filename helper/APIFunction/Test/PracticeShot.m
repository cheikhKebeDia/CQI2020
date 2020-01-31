function [missileHit, gameEnd] = PracticeShot(gameId, api_key, missileType, column, row, uri)
    missileHit = false;
    gameEnd = false;
    
    uri = uri + "/practice/shot/" + gameId

    contentTypeField = matlab.net.http.field.ContentTypeField('application/json');

    type = matlab.net.http.MediaType('application/json');
    acceptField = matlab.net.http.field.AcceptField([type]);
    xApiKey = matlab.net.http.field.GenericField("X-apikey",api_key);
    
    col = struct("column", column, "row", row);
    data = struct("missileType", missileType, "parameters", col);
    body = matlab.net.http.MessageBody(data);

    header = [contentTypeField acceptField xApiKey];
    method = matlab.net.http.RequestMethod.POST;

    request = matlab.net.http.RequestMessage(method,header,body);
    
    response = send(request,uri);
  
    array = response.Body.Data;
    json = jsondecode(convertCharsToStrings(char(array)));
    missileHit = false;
    gameEnd = false;
end
