#!/usr/bin/env python3
import yaml
from aws_cdk import App, Environment
from cloud1_stack import Cloud1Stack

with open("cdk/config.yml") as f:
    config = yaml.safe_load(f)

app = App()
Cloud1Stack(app, "Cloud1Stack", config=config,
            env=Environment(account="666531395015", region=config["region"]))
app.synth()
