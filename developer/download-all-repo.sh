#!/bin/bash

## Default settings that can be overwritten

## The complete list of kubeflow projects that can be downloaded locally
GIT_ACCOUNT=${GIT_ACCOUNT:-kubeflow}
PROTOCOL=${PROTOCOL:-"https://github.com/"}  ## alt: "git@github.com:" <-- remember the ':'

declare -a code=(
   "arena"
   "batch-predict"
   "fairing"
   "katib"
   "kfctl"
   "kfserving"
   "kubebench"
   "kubeflow"
   "metadata"
   "pipelines"
   ## OPERATORS
   "caffe2-operator"
   "chainer-operator"
   "common"
   "mpi-operator"
   "mxnet-operator"
   "pytorch-operator"
   "tf-operator"
   "xgboost-operator"
   ## Other
   "examples"
   "example-seldon"
   "testing"
   )

declare -a other=(
   "community"
   "manifests"
   "marketing-materials"
   "website"
   )

declare -a ignored=(
   "crd-validation"
   "features"
   "homebrew-cask"
   "homebrew-core"
   "inter-acls"
   "Issue-Label-Bot"
   "reporting"
   )

## now loop through the above array
for i in "${code[@]}" "${other[@]}" ; do
  if [ -d "$i" ]; then
    echo -n "Entering $i.. "
    cd "$i"
    git pull
    cd ..
  else
    git clone "${PROTOCOL}/${GIT_ACCOUNT}/$i"
  fi
done

# for i in "${other[@]}" ; do
#   git clone "${PROTOCOL}/${GIT_ACCOUNT}/$i"
# done
