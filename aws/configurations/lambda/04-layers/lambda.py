import os
import requests

def handler(context, event):
    server_dns = os.getenv("NGINX")
    resp = requests.get(f"http://{server_dns}")
    return {'statusCode': 200, 'message': resp.text}

