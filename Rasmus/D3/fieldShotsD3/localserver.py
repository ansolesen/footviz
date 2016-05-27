import subprocess
subprocess.Popen("python -m SimpleHTTPServer", shell=True)
subprocess.Popen('chrome "http://localhost:8000/"')
