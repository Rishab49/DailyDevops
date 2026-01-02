import requirements
import sys
from packaging.version import Version


try:
    with open("requirements.txt","r"):
        print("Starting execution")
except FileNotFoundError:
    print("requirements.txt does not exist")
    sys.exit(1)


forbidden=[
    {
        "package_name":"flask",
        "version":"0.1",
        "requirement": "=="
    },
    {
        "package_name":"requests",
        "version":"2.0.1",
        "requirement": "<"
    }
]

def check_package(package_name,specs):
    for item in forbidden:
        if item["package_name"] == package_name:
            for spec in specs:
                expr = f'Version("{spec[1]}") {item["requirement"]} Version("{item["version"]}")'
                #print(expr)
                result = eval(expr)
                if result:
                    sys.exit(1)
                #else:
                    #print("passed",expr)  

try:
    with open("requirements.txt","r",encoding="utf-8") as f:
        for package in requirements.parse(f):
            check_package(package.name,package.specs)
except FileNotFoundError:
    print("requirements.txt file does not exists")









