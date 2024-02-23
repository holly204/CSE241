import os
result = os.popen("curl http://google.es").read()
print(result)
