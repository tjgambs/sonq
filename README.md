# Titan API

### Google Cloud Deployment
``` bash
# Titan API is located at /home

# Kill all pids on Port 80 
sudo kill $( sudo lsof -i:80 -t )

# Delete old folder 
sudo rm -r titan-api

# Upload new titan-api zip

# Unzip titan-api
unzip titan-api.zip

cd titan-api

# Start titan-api 
nohup sudo gunicorn --bind 0.0.0.0:80 main:app &
```
