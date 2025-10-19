#!/bin/bash
/entrypoint.sh run-script compile
/entrypoint.sh run-script install

echo "Applying Post-Build patches..."
bash /tmp/demo-patch-scripts/apply-runtime-patches.sh

pushd /tmp && bash ./ocpp201-sp-config.sh && popd
