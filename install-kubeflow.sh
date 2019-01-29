#!/usr/bin/env bash

set -e  # exit immediately on error
set -u  # fail on undeclared variables

export KFAPP=${KFAPP:-my_kubeflow} # used to store the ksonnet artifacts (your kubeflow stack)
export KS_VER=${KS_VER:-0.13.1}      # the version of ksonnet to use
export KUBEFLOW_VERSION=${KUBEFLOW_VERSION:-0.4.1}  # the version of kubeflow to use
export KUBEFLOW_SRC=${KUBEFLOW_SRC:-"${HOME}/kubeflow/${KUBEFLOW_VERSION}"}

# Grab the directory of the scripts, in case the script is invoked from a different path
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# Useful routines in common.sh
. "${SCRIPTS_DIR}/common.sh"

#
# if ks doesn't exist on the path, then install it, using KS_VER to choose the version
#
function ensure_ksonnet() {
  if ! hash ks &>/dev/null; then
    wget https://github.com/ksonnet/ksonnet/releases/download/v${KS_VER}/ks_${KS_VER}_linux_amd64.tar.gz -O ksonnet.tar.gz
    mkdir -p ksonnet
    tar -xvf ksonnet.tar.gz -C ksonnet --strip-components=1
    sudo cp ksonnet/ks /usr/local/bin
    rm -fr ksonnet
    rm ksonnet.tar.gz
  else
    info "Skipping ksonnet download - binary already exists."
  fi
}

#
# Download the key parts of kubeflow - scripts and the ksonnet packages
#
function download_kubeflow() {
  if [ ! -d ${KUBEFLOW_SRC} ]; then
    info "Creating Kubeflow source directory: ${KUBEFLOW_SRC}"
    mkdir -p ${KUBEFLOW_SRC}
    pushd ${KUBEFLOW_SRC}
    curl https://raw.githubusercontent.com/kubeflow/kubeflow/v${KUBEFLOW_VERSION}/scripts/download.sh | bash
    popd
  else
    info "Skipping Kubeflow download - source directory already exists: ${KUBEFLOW_SRC}"
  fi
}

#
# Setup the core components of Kubeflow
#
function setup_kubeflow() {
  if [ ! -d ${KFAPP} ]; then
    info "Creating Kubeflow app directory: ${PWD}/${KFAPP}"
    ${KUBEFLOW_SRC}/scripts/kfctl.sh init ${KFAPP} --platform none &>/dev/null
    pushd ${KFAPP}
    ${KUBEFLOW_SRC}/scripts/kfctl.sh generate k8s &>/dev/null
  else
    info "Kubeflow app directory already exists: ${PWD}/${KFAPP}"
    pushd ${KFAPP}
  fi
}

#
# Setup the core components of Kubeflow
#
function customize_kubeflow() {
  # Put changes here ..
  # Look at ${KUBEFLOW_SRC}/scripts/util.sh::createKsApp for reference to core components
  # Run 'ks param list' in ks_app directory to get complete list of params
  pushd "ks_app"
  # change default config of some web UIs to be accessible externally
  ks param set ambassador ambassadorServiceType NodePort
  # Don't need to expose jupyterhub directly .. can access through ambassador.
  # But leaving it hear for illustration
  ks param set jupyter serviceType NodePort

  # Other components can be installed with 'ks pkg install / ks generate'
  # ...
  popd
}

#
# This will apply all of the kubeflow components to the k8s cluster
#
function apply_kubeflow() {
  ${KUBEFLOW_SRC}/scripts/kfctl.sh apply k8s
}


#
# Since it takes a while for container images to download and start running, calling this
# function will help monitor status
#
function wait_for_kubeflow() {
  until [[ `kubectl get pods -n=kubeflow | grep -o 'ContainerCreating' | wc -l` == 0 ]] ; do
    echo "Checking kubeflow status until all pods are running ("`kubectl get pods -n=kubeflow | grep -o 'ContainerCreating' | wc -l`" not running). Sleeping for 10 seconds."
    sleep 10
  done
}


ensure_ksonnet
download_kubeflow
setup_kubeflow
customize_kubeflow
apply_kubeflow
wait_for_kubeflow
. "${SCRIPTS_DIR}/print_ports.sh"
