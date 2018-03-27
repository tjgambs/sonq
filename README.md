# Titan API

### Google Cloud Deployment
Titan API is located at /home
1. Kill all pids on Port 80 <code>sudo kill $( sudo lsof -i:80 -t )</code>
2. Delete old folder <code>sudo rm -r titan-api</code>
3. Upload new titan-api zip
4. Unzip titan-api <code>unzip titan-api.zip</code>
5. <code>cd titan-api</code>
6. Start titan-api <code>nohup sudo gunicorn --bind 0.0.0.0:80 main:app &</code>
