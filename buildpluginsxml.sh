#!/bin/bash

#
# This script will rebuild and redeploy the SageTVPuginsV9.xml
# it should be called like the following
# GIT_COMMIT=true GIT_TOKEN=git_username:git_pat ./buildpluginsxml.sh
#

PLUGIN_DIR=plugins PLUGIN_BASENAME=SageTVPluginsV9 ./buildxml.sh
PLUGIN_DIR=beta-plugins PLUGIN_BASENAME=SageTVPluginsV9Beta ./buildxml.sh
