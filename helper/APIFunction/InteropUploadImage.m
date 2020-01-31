function [success] = InteropUploadImage(cookie, imageId, uri, missionId, cropImage)
    uri = uri + "/api/odlcs/" + imageId + "/image";
    body = matlab.net.http.MessageBody({cropImage,'jpg','Quality',50});
    
    request = matlab.net.http.RequestMessage('post', matlab.net.http.field.ContentTypeField('image/jpeg'),body);
    request = request.addFields(matlab.net.http.field.CookieField([cookie.Cookie]));
    
    response = send(request,uri);
    success = true;
end


