from fastapi import FastAPI, Request
import requests
import os

app = FastAPI()

CONDUCTOR_URL = "http://conductor.case.org:8080/api/workflow/deploy_server"

@app.post("/netbox-hook")
async def webhook(request: Request):
    data = await request.json()

    device = data["data"]
    status = device["status"]["value"]

    if status == "deploy":

        workflow_input = {
            "device_id": device["id"],
            "device_name": device["name"],
            "primary_ip": device["primary_ip4"]["address"].split("/")[0]
        }

        requests.post(CONDUCTOR_URL, json=workflow_input)

    return {"ok": True}
