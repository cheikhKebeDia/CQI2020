function [rounds] = ProductionPublicTournaments(token, uri)

    uri = uri + "/tournaments";

    header = matlab.net.http.HeaderField('X-token',token);
    method = matlab.net.http.RequestMethod.GET;
    body = [];

    request = matlab.net.http.RequestMessage(method,header,body);

    response = send(request,uri);
  
    publicTournamentsDecoded = jsondecode(convertCharsToStrings(char(response.Body.Data)));
    rounds = publicTournamentsDecoded.publicTournaments.rounds;
    
end