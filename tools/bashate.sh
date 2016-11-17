#!/usr/bin/env bash

echo "Executing Bashate (https://github.com/openstack-dev/bashate)"
#if bashate sample_script.sh; then
#    echo "Bashate exited without errors."
#fi
bash -c "grep -Irl \
        -e '!/usr/bin/env bash' \
        -e '!/bin/bash' \
        -e '!/bin/sh' \
        --exclude-dir '.*' \
        --exclude-dir 'DOCs-OPS-Newton' \
        --exclude-dir 'RDO-OpenStack-Newton-Guide' \
        --exclude-dir '*.egg-info' \
        --exclude 'bashate.sh' \
        --exclude '*.md' \
        --exclude '*.txt' \
        ../"
