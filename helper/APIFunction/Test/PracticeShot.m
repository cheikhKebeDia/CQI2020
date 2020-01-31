function [missileHit, gameEnd] = PracticeShot(gameId, uri)
    missileHit = false;
    gameEnd = false;
    
    uri = uri + "/practice/shot/" + gameId;

    contentTypeField = matlab.net.http.field.ContentTypeField('application/json');

    type = matlab.net.http.MediaType('application/json');
    acceptField = matlab.net.http.field.AcceptField([type]);

    header = [acceptField contentTypeField];
    method = matlab.net.http.RequestMethod.GET;
    body = [];

    request = matlab.net.http.RequestMessage(method,header,body);
    request = request.addFields(matlab.net.http.field.CookieField([cookie.Cookie]));
    
    response = send(request,uri);
  
    missionSetting = response.Body.Data
    response.Header
    
end
