# ADLC
Vamudes ADLC

# TODO
 - Adding params to the function
    - Image (resize by section)
 - Adding filter params in Global file


- Le image devrais être toujours de la même grosseur pour pouvoir regarder la grosseur en pixel des blop
- INFO : https://www.mathworks.com/help/parallel-computing/establish-arrays-on-a-gpu.html#bsic48l

# To config

You have to change this value in the code : 
```
% Interop
uri = "http://localhost:8000";
username = "testadmin";
password = "testpass";
missionId = 1;

% Image folder
path_to_folder = "Image/terrain/";
```

And add the correct featcher you need to detect :

```
% What to take
OCROn = false;
dominantColorOn = false;
findTemplateOn = true;
InteropOn = false;
```