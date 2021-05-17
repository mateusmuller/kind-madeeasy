# KIND made easy

## What a hell is this project?

I am currently using [kind](https://kind.sigs.k8s.io/) to build the Kubernetes cluster locally for my experiments, and therefore, I faced a problem: **Recreate the cluster**.

To recreate the whole thing I had to deploy the Ingress controller and the monitoring stack once again and modify some stuff on the control plane so Prometheus is able to scrape the metrics.

So I came up with this script and I hope it helps you as well.

## Requirements

You should have at least **docker** and **curl** installed.

## How to use it?

```
$ git clone https://github.com/mateusmuller/kind-madeeasy
$ cd kind-madeeasy/
$ ./main.sh --cluster-name demo
```

That's it. It will download kind, kubectl and helm (if they don't exist yet) and build the whole thing.

If you just want the cluster, you can disable the two things with `--no-monitoring` and `--no-nginx`.

Feel free to contribute.