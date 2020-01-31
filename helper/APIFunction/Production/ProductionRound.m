function [games] = ProductionRound(token, uri, roundId)
    uri = uri + "/tournaments/rounds/?"+roundId;

    header = matlab.net.http.HeaderField('X-token',token);
    method = matlab.net.http.RequestMethod.GET;
    body = [];

    request = matlab.net.http.RequestMessage(method,header,body);

    response = send(request,uri);
  
    filteredResponse = response.Body.Data.games;
    games = jsonencode(convertCharsToStrings(char(filteredResponse)));
    
end

