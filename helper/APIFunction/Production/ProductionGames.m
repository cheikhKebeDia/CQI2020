function [isReady] = ProductionGames(token, uri, gamesId)
    uri = uri + "/tournaments/rounds/?games"+gamesId;

    header = matlab.net.http.HeaderField('X-token',token);
    method = matlab.net.http.RequestMethod.GET;
    body = [];

    request = matlab.net.http.RequestMessage(method,header,body);

    response = send(request,uri);
  
    response = response.Body.Data.ready;
    isReady = jsonencode(convertCharsToStrings(char(response)));
end

