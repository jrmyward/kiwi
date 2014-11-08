#!/bin/bash

mina deploy_assets host=frontend001.forekast.com
mina full_deploy host=fkweb003.forekast.com
mina full_deploy host=fkweb004.forekast.com
mina update_cron host=fkweb003.forekast.com
