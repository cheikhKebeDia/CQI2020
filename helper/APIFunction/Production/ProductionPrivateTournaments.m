function [rounds] = ProductionPrivateTournaments(token, uri)

    uri = uri + "/tournaments";

    header = matlab.net.http.HeaderField('X-token',token);
    method = matlab.net.http.RequestMethod.GET;
    body = [];

    request = matlab.net.http.RequestMessage(method,header,body);

    response = send(request,uri);
  
    privateTournamentsDecoded = jsondecode(convertCharsToStrings(char(response.Body.Data)));
    rounds = privateTournamentsDecoded.privateTournaments.rounds;
    
 
end
