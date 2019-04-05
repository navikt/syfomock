#!/usr/bin/env bash

version="$(date +'%m.%d.%H%M')-$(git rev-parse --short HEAD)"
echo "$version"

docker build --build-arg version=latest --build-arg app_name=syfomock -t "repo.adeo.no:5443/syfo/syfomock:$version" .

docker push "repo.adeo.no:5443/syfo/syfomock:$version"

sed -e "s/{{VERSION}}/$version/g" nais.yaml > dist/nais.yaml

kubectl apply --context dev-sbs --namespace default -f dist/nais.yaml

kubectl --context dev-sbs --namespace default rollout status -w deployment/syfomock
