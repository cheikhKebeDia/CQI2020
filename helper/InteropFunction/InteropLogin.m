function [cookie] = InteropLogin(username, password, uri)
    cookie = '';
    uri = uri + "/api/login";

    contentTypeField = matlab.net.http.field.ContentTypeField('application/json');
    data = struct("username", username, "password", password);
    body = matlab.net.http.MessageBody(data);

    type = matlab.net.http.MediaType('application/json');
    acceptField = matlab.net.http.field.AcceptField([type]);

    header = [acceptField contentTypeField];
    method = matlab.net.http.RequestMethod.POST;

    request = matlab.net.http.RequestMessage(method,header,body);

    response = send(request,uri);

    setCookieFields = response.getFields('Set-Cookie');
    cookie = setCookieFields.convert;
    %cookie =  erase(string(cookieInfos.Cookie), "sessionid=");
end



