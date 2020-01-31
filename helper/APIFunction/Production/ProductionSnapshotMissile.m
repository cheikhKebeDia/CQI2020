function [missileData] = ProductionSnapshotMissile(token, uri, gamesId, column, row)
    uri = uri + "/tournaments/rounds/games/"+gamesId;

    contentTypeField = matlab.net.http.field.ContentTypeField('application/json');
    data = struct("missileType", "snapshot", "parameters",struct("column", column, "row", row));
    body = matlab.net.http.MessageBody(data);

    type = matlab.net.http.MediaType('text/*');
    acceptField = matlab.net.http.field.AcceptField([type]);
    
    xToken = matlab.net.http.field.GenericField("X-token",token);
    
    header = [contentTypeField acceptField xToken];
    method = matlab.net.http.RequestMethod.POST;

    request = matlab.net.http.RequestMessage(method,header,body);
    response = send(request,uri);
    
    decodedResponse = jsondecode(convertCharsToStrings(char(response.Body.Data)));
    missileData = base64decode(decodedResponse.missileData);
end

