#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in CI
# DOCKER_USERNAME
# DOCKER_PASSWORD

set -ex

#set -e

install_jq() {
  # jq 1.6
  DEBIAN_FRONTEND=noninteractive
  #sudo apt-get update && sudo apt-get -q -y install jq
  curl -sL https://github.com/stedolan/jq/releases/download/jq-1.7/jq-linux64 -o jq
  sudo mv jq /usr/bin/jq
  sudo chmod +x /usr/bin/jq
}

build() {
  # vals latest
  vals_version=$(curl -s https://api.github.com/repos/helmfile/vals/releases | jq -r '.[].tag_name | select(startswith("v"))' \
    | sort -rV | head -n 1 |sed 's/v//')
  echo "vals version is $vals_version"

  # kubeconform latest
  kubeconform_version=$(curl -s https://api.github.com/repos/yannh/kubeconform/releases | jq -r '.[].tag_name | select(startswith("v"))' \
    | sort -rV | head -n 1 |sed 's/v//')
  echo "kubeconform version is $kubeconform_version"

  docker build --no-cache \
    --build-arg KUBECTL_VERSION=${tag} \
    --build-arg VALS_VERSION=${vals_version} \
    --build-arg KUBECONFORM_VERSION=${kubeconform_version} \
    -t ttl.sh/${IMAGE_NAME}:1h .
  docker push ttl.sh/${IMAGE_NAME}:1h

}
image="rkenefeck/k8s"
IMAGE_NAME=$(uuidgen)

install_jq

# Get the list of all releases tags, excludes alpha, beta, rc tags
releases=$(curl -s https://api.github.com/repos/kubernetes/kubernetes/releases | jq -r '.[].tag_name | select(test("alpha|beta|rc") | not)')

# Loop through the releases and extract the minor version number
for release in $releases; do
  minor_version=$(echo $release | awk -F'.' '{print $1"."$2}')
  
  # Check if the minor version is already in the array of minor versions
  if [[ ! " ${minor_versions[@]} " =~ " ${minor_version} " ]]; then
    minor_versions+=($minor_version)
  fi
done

# Sort the unique minor versions in reverse order
sorted_minor_versions=($(echo "${minor_versions[@]}" | tr ' ' '\n' | sort -rV))

# Loop through the first 4 unique minor versions and get the latest version for each
for i in $(seq 0 3); do
  minor_version="${sorted_minor_versions[$i]}"
  latest_version=$(echo "$releases" | grep "^$minor_version\." | sort -rV | head -1 | sed 's/v//')
  latest_versions+=($latest_version)
done

echo "Found k8s latest versions: ${latest_versions[*]}"

for tag in "${latest_versions[@]}"; do
  echo ${tag}
  status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag})
  echo $status
  if [[ ( "${status}" =~ "not found" ) ||( ${REBUILD} == "true" ) ]]; then
     echo "build image for ${tag}"
     build
  fi
done