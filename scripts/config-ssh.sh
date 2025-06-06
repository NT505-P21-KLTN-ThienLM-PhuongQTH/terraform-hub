#!/bin/bash

mkdir -p /home/ubuntu/.ssh
cat <<EOF > /home/ubuntu/.ssh/authorized_keys
${authorized_keys_content}
EOF