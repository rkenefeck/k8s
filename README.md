# All-In-One Kubernetes tools (kubectl, kubeconform)

kubernetes docker images with necessary tools 


### Notes

(1) **There is no `latest` tag for this image**

(2) If you need more tools to be added, raise tickets in issues.

(3) This image supports `linux/amd64,linux/arm64` platforms now, updated on 15th Feb 2023 with [#54](https://github.com/alpine-docker/k8s/pull/54)

### Installed tools

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (latest minor versions: https://kubernetes.io/releases/)
- [vals](https://github.com/helmfile/vals) (latest version when run the build)
- [kubeconform](https://github.com/yannh/kubeconform) (latest version when run the build)
- General tools, such as bash, curl, jq, yq, etc

### Github Repo

https://github.com/rkenefeck/k8s


# Why we need it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment

# kubectl versions

You should check in [kubernetes versions](https://kubernetes.io/releases/), it lists the kubectl latest minor versions and used as image tags.

# Involve with developing and testing

If you want to build these images by yourself, please follow below commands.

```
export REBUILD=true
# comment the line in file "build.sh" to stop image push:  docker push ${image}:${tag}
bash ./build.sh
```

Second thinking, if you are adding a new tool, make sure it is supported in both `linux/amd64,linux/arm64` platforms



