#!/bin/bash

mina deploy_assets host=frontend001.forekast.com  branch=speed_improvements
mina full_deploy host=fkweb003.forekast.com branch=speed_improvements
mina full_deploy host=fkweb004.forekast.com branch=speed_improvements
mina update_cron host=fkweb003.forekast.com branch=speed_improvements
