&nbsp;

<p align="center">
    Brought to you by
</p>

<p align="center">
  <a href="https://firepress.org/">
    <img src="https://user-images.githubusercontent.com/6694151/50166045-2cc53000-02b4-11e9-8f7f-5332089ec331.jpg" width="340px" alt="FirePress" />
  </a>
</p>

<p align="center">
    <a href="https://firepress.org/">FirePress.org</a> |
    <a href="https://play-with-ghost.com/">play-with-ghost</a> |
    <a href="https://github.com/firepress-org/">GitHub</a> |
    <a href="https://twitter.com/askpascalandy">Twitter</a>
    <br /> <br />
</p>

&nbsp;

# [resilio-in-docker](https://github.com/firepress-org/resilio-in-docker)

## What is this?

A slim docker image for **Resilio Sync** using best practices available.

## Features

- an **everyday build** and on every commit (CI)
- a build from the **sources** (CI)
- a logic of **four docker tags** on the master branch (CI) and logic of **three docker tags** on any other branches (CI)
- few UAT **tests** (CI)
- an automatic push of the **README** to Dockerhub (CI)
- **Slack** notifications when a build succeed (Job 2) (CI)
- a **multi-stage** build (Dockerfile)
- an **alpine** base docker image (Dockerfile)
- **Labels** (Dockerfile)
- this app is compressed using **UPX** (Dockerfile)
- a **small footprint** docker image's size (Dockerfile)
- `utility.sh` based on [bash-script-template](https://github.com/firepress-org/bash-script-template)
- and probably more, but hey, who is counting?

**To add in the future**:
- a **non-root** user (Dockerfile)
- having this app running as PID 1 under **tiny** (Dockerfile)

## About Resilio Sync

[Resilio Sync](https://www.resilio.com/connect/) is a fast, reliable, and simple file sync and share solution, powered by a P2P technology.

![loading](https://user-images.githubusercontent.com/6694151/64082499-f4e50800-ccdd-11e9-827c-66dfb380a321.gif)

## How to use it, Docker hub

<details><summary>Expand content (click here).</summary>
<p>

## How to use it

```
LOCAL_STORAGE="~/resilio/data"
CTN_NAME="resilio"
IMG_resilio="devmtl/resilio:2.6.3_2019-09-10_18H15s21_0383a37"
```

### Simple run

```
docker run --rm \
  -v $LOCAL_STORAGE:/data \
  -p 33333:33333 \
  "$IMG_resilio" sh -c \
  "rslsync --help" && echo

```

### Generate RSLSYNC_SECRET from Node 1

```
docker run -d \
  --name ${CTN_NAME} \
  -v ${LOCAL_STORAGE}:/data \
  -p 33333:33333 \
  ${IMG_resilio}
```

### Display RSLSYNC_SECRET

```
docker logs -f ${CTN_NAME};
```

### Join existing resilio cluster using RSLSYNC_SECRET on Nodes 2, 3, N

```
MY_TOKEN="AJR3101010010110101010101010KH"

docker run -d `
  --name "$CTN_NAME" \
  -v $LOCAL_STORAGE:/data \
  -p 33333:33333 \
  -e RSLSYNC_SECRET="$MY_TOKEN" \
  "$IMG_resilio"; echo;
```

### Production ready example using docker service on Swarm

```
# node 1
docker service create \
  --name ${CTN_resilio1} --hostname ${CTN_resilio1} \
  --network ${NTW_RESILIO} --replicas "1" \
  --restart-condition "any" --restart-max-attempts "20" \
  --reserve-memory "192M" --limit-memory "512M" \
  --limit-cpu "0.333" \
  --constraint 'node.labels.nodeid == 1' \
  --publish "33331:33333" \
  -e RSLSYNC_SECRET=$(cat ${secret_token_path}) \
  --mount type=bind,source=${LOCAL_STORAGE},target=/data \
  ${IMG_resilio}

# node 2
docker service create \
  --name ${CTN_resilio2} --hostname ${CTN_resilio2} \
  --network ${NTW_RESILIO} --replicas "1" \
  --restart-condition "any" --restart-max-attempts "20" \
  --reserve-memory "192M" --limit-memory "512M" \
  --limit-cpu "0.333" \
  --constraint 'node.labels.nodeid == 2' \
  --publish "33332:33333" \
  -e RSLSYNC_SECRET=$(cat ${secret_token_path}) \
  --mount type=bind,source=${LOCAL_STORAGE},target=/data \
  ${IMG_resilio}

# node 3
docker service create \
  --name ${CTN_resilio3} --hostname ${CTN_resilio3} \
  --network ${NTW_RESILIO} --replicas "1" \
  --restart-condition "any" --restart-max-attempts "20" \
  --reserve-memory "192M" --limit-memory "512M" \
  --limit-cpu "0.333" \
  --constraint 'node.labels.nodeid == 3' \
  --publish "33333:33333" \
  -e RSLSYNC_SECRET=$(cat ${secret_token_path}) \
  --mount type=bind,source=${LOCAL_STORAGE},target=/data \
  ${IMG_resilio}
```

## CI configuration & Github Actions

[See README-CI.md](./README-CI.md)

## Docker hub

Always check on docker hub the most recent build:<br>
https://hub.docker.com/r/devmtl/noti/tags

You should use **this tag format** in production.<br>
`${VERSION} _ ${DATE} _ ${HASH-COMMIT}` 

```
devmtl/resilio:2.6.3_2019-09-10_18H15s21_0383a37
```

These tags are also available to try stuff quickly:

```
devmtl/resilio:2.6.3
devmtl/resilio:stable
devmtl/resilio:latest
```

## Related docker images

[See README-related.md](./README-related.md)

</p>
</details>


## Website hosting

If you are looking for an alternative to WordPress, [Ghost](https://firepress.org/en/faq/#what-is-ghost) might be the CMS you are looking for. Check out our [hosting plans](https://firepress.org/en).

![ghost-v2-review](https://user-images.githubusercontent.com/6694151/64218253-f144b300-ce8e-11e9-8d75-312a2b6a3160.gif)


## Why, Contributing, License

<details><summary>Expand content (click here).</summary>
<p>

## Why all this work?

Our [mission](https://firepress.org/en/our-mission/) is to empower freelancers and small organizations to build an outstanding mobile-first website.

Because we believe your website should speak up in your name, we consider our mission completed once your site has become your impresario.

Find me on Twitter [@askpascalandy](https://twitter.com/askpascalandy).

— [The FirePress Team](https://firepress.org/) 🔥📰

## Contributing

The power of communities pull request and forks means that `1 + 1 = 3`. You can help to make this repo a better one! Here is how:

1. Fork it
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

Check this post for more details: [Contributing to our Github project](https://pascalandy.com/blog/contributing-to-our-github-project/). Also, by contributing you agree to the [Contributor Code of Conduct on GitHub](https://pascalandy.com/blog/contributor-code-of-conduct-on-github/). 

## License

- This git repo is under the **GNU V3** license. [Find it here](./LICENSE).

</p>
</details>
