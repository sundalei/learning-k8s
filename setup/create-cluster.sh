echo "Generate kind config with local absolute paths for PV mounts"

REPLACE_WITH_ABSOLUTE_PATH=${PWD} envsubst < kind-config.yaml.TEMPLATE > kind-config.yaml

echo "Create a Kubernetes cluster using kind"

kind create cluster --config kind-config.yaml