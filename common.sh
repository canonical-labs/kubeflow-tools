#!/bin/bash

######################
## Common Variables ##
######################
VM_IMAGE=${VM_IMAGE:-"bionic"}
VM_NAME=${VM_NAME:-"my_vm"}
RED='\033[1;31m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

######################
## Common Functions ##
######################

function info() {
  printf "${BLUE}${@}${NC}\n"
}

function error() {
  printf "${RED}${@}${NC}\n"
}

# Print the error and exit with status code 1
function exit_error() {
  printf "${RED}${@}${NC}\n"
  exit 1
}

# If we need to run as root, call this function
function ensure_root() {
  if [[ $EUID -ne 0 ]]; then
    exit_error "This script should run using sudo or as the root user"
  fi
}

function ensure_binary() {
  if ! hash ${2} &>/dev/null; then
    exit_error "Please install ${2} and ensure it is on your path."
  fi
}
