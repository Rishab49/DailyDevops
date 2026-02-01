import subprocess
import io
import csv
output=subprocess.run("echo 'show stat rgw' | socat stdio /var/lib/haproxy/stats", shell=True,capture_output=True)
raw_text = output.stdout.decode('utf-8').strip().lstrip('# ')
stream=io.StringIO(raw_text)
reader=csv.DictReader(stream)

# print(output.stdout)

result={
    "counter":0,
    "database_status": "NOT OK",
    "lb_status": "NOT OK"
}

for row in reader:
    if row['status'] == "UP":
        result["counter"] +=1;

output=subprocess.run("sudo systemctl status mysqld",shell=True,capture_output=True)
if(output.returncode == 0):
    result["database_status"] = "OK"

output=subprocess.run("sudo systemctl status haproxy",shell=True,capture_output=True)
if(output.returncode == 0):
    result["lb_status"] = "OK"


print(result)