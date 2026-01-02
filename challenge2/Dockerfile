FROM python:3.12-alpine AS stage1
COPY ./requirements.txt check_app.py .
RUN pip install requirements-parser
RUN python ./check_app.py

FROM python:3.13-alpine
COPY --from=stage1 requirements.txt .
CMD ["python","-c","print('App is safe')"]
