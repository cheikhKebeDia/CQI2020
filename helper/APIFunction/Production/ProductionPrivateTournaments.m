function [rounds] = ProductionPrivateTournaments(token, uri)

    uri = uri + "/tournaments";

    header = matlab.net.http.HeaderField('X-token',token);
    method = matlab.net.http.RequestMethod.GET;
    body = [];

    request = matlab.net.http.RequestMessage(method,header,body);

    response = send(request,uri);
  
    privateTournaments = response.Body.Data.privateTournaments;
    rounds = jsonencode(convertCharsToStrings(char(privateTournaments))).rounds;
 
end
