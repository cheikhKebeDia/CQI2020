function [missileHit, gameEnd, missileData] = PracticeShot(gameId, api_key, missileType, column, row, uri)
    missileHit = false;
    gameEnd = false;
    
    uri = uri + "/practice/shot/" + gameId;

    contentTypeField = matlab.net.http.field.ContentTypeField('application/json');

    type = matlab.net.http.MediaType('application/json');
    acceptField = matlab.net.http.field.AcceptField([type]);
    xApiKey = matlab.net.http.field.GenericField("X-apikey",api_key);
    
    if missileType == "snapshot" 
        col = struct("column", column, "row", row);
        data = struct("missileType", missileType, "parameters", col);
    elseif missileType == "sonar"
        if column == -1
            col = struct("row", row);
        else
            col = struct("column", column);
        end
        data = struct("missileType", missileType, "parameters", col);
    end
    body = matlab.net.http.MessageBody(data);

    header = [contentTypeField acceptField xApiKey];
    method = matlab.net.http.RequestMethod.POST;

    request = matlab.net.http.RequestMessage(method,header,body);
    
    response = send(request,uri);
  
    array = response.Body.Data;
    json = jsondecode(convertCharsToStrings(char(array)));
    missileData = base64decode(json.missileData);
    missileHit = false;
    gameEnd = false;
end
