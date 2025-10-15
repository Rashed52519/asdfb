# main.py
from fastapi import FastAPI
from fastapi.responses import JSONResponse, RedirectResponse

app = FastAPI()

# عدّل القيم هنا فقط ثم أعد النشر
VERSION = {
    "latest_version": "1.11",
    "update_type": "optional",  # "optional" أو "force"
    "app_store_link": "https://google.com"
}

@app.get("/version")
async def get_version():
    return JSONResponse(VERSION)

@app.get("/")
async def root():
    return RedirectResponse(url="/version", status_code=302)
