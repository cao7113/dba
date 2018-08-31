#!/usr/bin/env dockerdba runscript --keep

pga gen_datafile starup_staging_agentcloud
echo edit your data rules at datafiles/
# todo
sh
pga copy starup_staging_agentcloud docker_ac1
