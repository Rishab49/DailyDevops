Challenge 02: The Pre-Flight Validator
To bridge Bucket C (Logic/CI/CD) and Bucket B (Orchestration), you must move from simple S3 to Docker.

Scenario: Your team is moving to containers. You need a script that "pre-flights" a Python application before it is allowed to be built into an image.

Task Requirements:

Logic (Bucket C): Create a Python script check_app.py. It should:

Read a file named requirements.txt.

Check if any forbidden libraries are listed (forbidden: flask==0.1, requests<2.0.0).

If forbidden libraries are found, exit with code 1.

Orchestration (Bucket B): Create a Dockerfile that:

Uses a lightweight Python image.

Runs your check_app.py as a RUN command during the build process.

If the script fails, the Docker build must fail.

If it passes, install the requirements and set a simple CMD ["python", "-c", "print('App is safe')"].

Success Criteria:

Submit check_app.py and the Dockerfile.

The Docker build must fail if I put flask==0.1 in requirements.txt.


# Solution

## check_app.py
The requirement of this challenge is to create a python script which will check the `requirements.txt` file and validate is for any forbidden libraries.

So we started our script with a check to confirm requirements.txt exists using the below snippet of code
```python
try:
    with open("requirements.txt","r"):
        print("Starting execution")
except FileNotFoundError:
    print("requirements.txt does not exist")
    sys.exit(1)
```

then we open the file and parse the requirements using `requirements_parser` package and passes the package name along with versioning information to check_package function 


```python

try:
    with open("requirements.txt","r",encoding="utf-8") as f:
        for package in requirements.parse(f):
            check_package(package.name,package.specs)
except FileNotFoundError:
    print("requirements.txt file does not exists")

```


which loops through the forbidden packages array 

```python
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
```

and if any package name matches with the passed package_name it performs a comparision between the given package_version and the forbidden package version using `eval()` method according the defined requirement if the comparision succeeds then it exits with 1 else it continues the program execution.

```python
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

```


## Dockerfile

Inside `Dockerfile` before making the final image we are testing the `requirements.txt` file using our script and if the script succeeds we are moving to next stage of build process else we are exiting the script

```Dockerfile
FROM python:3.12-alpine AS stage1
COPY ./requirements.txt check_app.py .
RUN pip install requirements-parser
RUN python ./check_app.py
```


in the second stage of build we are only copying the requirement.txt file from stage1, the reason we are deliberately copying from stage1 and creating dependency because multi stage build stages which does not depends on one anogher executes in paralle but we donot want that hence we are copying the `requirement.txt` file from stage1, also makes our final image size smaller.

```Dockerfile
FROM python:3.13-alpine
COPY --from=stage1 requirements.txt
CMD ["python","-c","print('App is safe')"]
```