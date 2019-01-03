#!/usr/bin/env bash

set -e  # exit immediately on error
set -u  # fail on undeclared variables

# Grab the directory of the scripts, in case the script is invoked from a different path
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# Useful routines in common.sh
. "${SCRIPTS_DIR}/common.sh"

#
# Print the key ports that can be used to access the UI.
#
function print_ports() {
  # Print port information
  AM_PORT=`kubectl get svc -n=kubeflow -o go-template='{{range .items}}{{if eq .metadata.name "ambassador"}}{{(index .spec.ports 0).nodePort}}{{"\n"}}{{end}}{{end}}'`
  JH_PORT=`kubectl get svc -n=kubeflow -o go-template='{{range .items}}{{if eq .metadata.name "tf-hub-lb"}}{{(index .spec.ports 0).nodePort}}{{"\n"}}{{end}}{{end}}'`
  echo ""
  echo "Ambassador Port: ${AM_PORT} ==> Access default Kubeflow UIs"
  echo "JupyterHub Port: ${JH_PORT} ==> Access JupyerHub directly"
  echo ""
}

print_ports
