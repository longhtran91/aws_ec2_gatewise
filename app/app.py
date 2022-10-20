from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles

import os, httpx, uvicorn

app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
  return templates.TemplateResponse("index.html", {"request": request})

@app.post("/open_gate")
async def open_gate():
  key = os.getenv('KEY')
  refreshToken = os.getenv('REFRESH_TOKEN')
  async with httpx.AsyncClient() as client:
    params = {
    'key': key,
    }
    data = {
        'grantType': 'refresh_token',
        'refreshToken': refreshToken,
    }
    response_token = await client.post('https://securetoken.googleapis.com/v1/token', params=params, data=data)

  async with httpx.AsyncClient() as client:
    user_agent = os.getenv('USER_AGENT')
    device_token = os.getenv('DEVICE_TOKEN')
    headers = {
      'Authorization': 'Bearer ' + response_token.json()["access_token"],
      'Accept-Language': 'en-us',
      'User-Agent': user_agent,
      'Accept-Encoding': 'gzip, deflate, br',
      'device-token': device_token,
      'Connection': 'keep-alive',
      'Accept': 'application/json, text/plain, */*',
      'Cache-Control': 'no-cache',
    }
    repsonse = await client.post ('https://portal.gatewise.com/api/v1/user/community/1695/access_point/5017/open', headers=headers)
  return repsonse.json()