function [succes, imageId] = InteropODLCSubmit(cookie, uri, missionId, ODLCStructure)
    uri = uri + "/api/odlcs";

    contentTypeField = matlab.net.http.field.ContentTypeField('application/json');
    data = struct("mission", missionId, "type", ODLCStructure.Type, "latitude", ODLCStructure.Latitude, "longitude", ODLCStructure.Longitude, "shape", ODLCStructure.Shape, "autonomous", true);
    body = matlab.net.http.MessageBody(data);

    type = matlab.net.http.MediaType('application/json');
    acceptField = matlab.net.http.field.AcceptField(type);

    header = [acceptField contentTypeField];
    method = matlab.net.http.RequestMethod.POST;

    request = matlab.net.http.RequestMessage(method,header,body);
    request = request.addFields(matlab.net.http.field.CookieField([cookie.Cookie]));

    response = send(request,uri);
    imageId = response.Body.Data.id;
    succes = true;
end



