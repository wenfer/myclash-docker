import datetime
import json
import os
import pathlib
from socket import AddressFamily

import psutil
import requests
import yaml
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from robyn import Robyn, Request, logger
from robyn.templating import JinjaTemplate

current_file_path = pathlib.Path(__file__).parent.resolve()
JINJA_TEMPLATE = JinjaTemplate(os.path.join(current_file_path, "templates"))

app = Robyn(__file__)


config = {}
scheduler = BackgroundScheduler()


def get_config_home():
    return os.path.join(os.path.expanduser("~"), ".config")


def download_config():
    if config is None:
        return
    try:
        res = requests.get(config['config_url'])
        clash_config = yaml.full_load(res.text)
        if config['port']:
            clash_config['port'] = config['port']
        if config['socks_port']:
            clash_config['socks-port'] = config['socks_port']
        clash_config['allow-lan'] = True
        clash_config['external-controller'] = f'{config["network"]}:{config["external_port"]}'
        if hasattr(config, 'secret'):
            clash_config['secret'] = config['secret']
        clash_config['external-ui'] = "/etc/clash-dashboard"
        clash_config['bind-address'] = config['network']
        yaml.dump(clash_config, open(os.path.join(get_config_home(), "config.yaml"), "w"))
    except BaseException as e:
        logger.error("更新配置失败")
        logger.error(e, exc_info=True)


def get_network_interfaces():
    # 获取所有网络接口信息
    interfaces = psutil.net_if_addrs()
    result = []
    # 遍历每个网络接口
    for interface_name, interface_addresses in interfaces.items():
        if interface_name == "lo":
            continue
        for address in interface_addresses:
            if address.family == AddressFamily.AF_INET or address.family == AddressFamily.AF_INET6:
                result.append({
                    "name": interface_name,
                    "address": address.address,
                })
    return result


@app.get("/")
async def index():
    context = {"ip_array": get_network_interfaces()}
    if os.path.exists(os.path.join(get_config_home(), "config.json")):
        with open(os.path.join(get_config_home(), "config.json"), "r") as f:
            context["config"] = json.load(f)
    return JINJA_TEMPLATE.render_template(template_name="index.html", **context)


@app.post("/")
async def save_config(request: Request):
    global config
    config = request.json()
    logger.info(f"更新配置:{config}")
    if config:
        if config["config_url"]:
            download_config()
        if config["cron"]:
            try:
                trigger = CronTrigger.from_crontab(config["cron"])
            except ValueError:
                return {
                    "code": -1,
                    "msg": "cron表达式有误"
                }
            job = scheduler.get_job("download_yaml")
            if job:
                scheduler.remove_job("download_yaml")
            now = datetime.datetime.now()
            logger.info(f"job next run time on {trigger.get_next_fire_time(now, now)}")
            scheduler.add_job(download_config, id="download_yaml", trigger=trigger)
        with open(os.path.join(get_config_home(), "config.json"), "w") as f:
            f.write(json.dumps(config))
    return {
        "code": 0,
        "msg": "success"
    }


if __name__ == "__main__":
    scheduler.start(paused=False)
    app.start(host="0.0.0.0", port=8080)
