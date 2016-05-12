#!/bin/bash

echo "127.0.0.1 `hostname`" >> /etc/hosts
/opt/atlassian/confluence/bin/start-confluence.sh -fg

