# [resilio-in-docker](https://github.com/firepress-org/resilio-in-docker)

A slim docker image for **Resilio Sync** using best practices available.

**It features**:

- A CI build made **every day** and on every commits
- A **multi-stage** build
- Image **tests** using docker-official tests
- A vulnerability checker using the **Aqua scanner**
- An easy to read **logs** within the CI history
- The push of **four tags** to registry
- The compression of the app (**UPX**)
- Detailed **Labels**
- The **Alpine** image in the final image
- A small foot print of about **31MB** (uncompressed) as this app relies on **glibc**

## About Resilio Sync

[Resilio Sync](https://www.resilio.com/connect/) is a fast, reliable, and simple file sync and share solution, powered by a P2P technology.

![loading](https://user-images.githubusercontent.com/6694151/64082499-f4e50800-ccdd-11e9-827c-66dfb380a321.gif)

<br>

## Regarding Github Actions & CI configuration

[See README-CI.md](./README-CI.md)

<br>

## Docker hub

Always check on docker hub the most recent build:<br>
[https://hub.docker.com/r/devmtl/resilio/tags](https://hub.docker.com/r/devmtl/resilio/tags)

You should use **this tag format** `$VERSION_$DATE_$HASH-COMMIT` in production.

```
devmtl/resilio:2.6.3_2019-09-01_16H28s32_399d1a6
```

These tags are also available to test stuff quickly:

```
devmtl/resilio:2.6.3
devmtl/resilio:stable
devmtl/resilio:latest
```

<br>


# How to use it

```
LOCAL_STORAGE="/Volumes/960G/_pascalandy/tmp2/resilio/data"
CTN_NAME="resilio"
IMG_resilio="devmtl/resilio:2.6.3_2019-09-01_16H28s32_399d1a6"
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

<br>

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

<br>

## Hosting

At FirePress we empower entrepreneurs and small organizations to create their websites on top of [Ghost](https://firepress.org/en/faq/#what-is-ghost).

At the moment, our **pricing** for hosting one Ghost website is $15 (Canadian dollars). This price will be only available for our first 100 new clients, starting May 1st, 2019 🙌. [See our pricing section](https://firepress.org/en/pricing/) for details.

More details [about this annoucement](https://forum.ghost.org/t/host-your-ghost-website-on-firepress/7092/1) on Ghost's forum.

<br>

## Contributing

The power of communities pull request and forks means that `1 + 1 = 3`. You can help to make this repo a better one! Here is how:

1. Fork it
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

Check this post for more details: [Contributing to our Github project](https://pascalandy.com/blog/contributing-to-our-github-project/). Also, by contributing you agree to the [Contributor Code of Conduct on GitHub](https://pascalandy.com/blog/contributor-code-of-conduct-on-github/). It's plain common sense really.

<br>

## License

- This git repo is under the **GNU V3** license. [Find it here](https://github.com/pascalandy/GNU-GENERAL-PUBLIC-LICENSE/blob/master/LICENSE.md).

<br>

## Why all this work?

Our [mission](https://firepress.org/en/our-mission/) is to empower freelancers and small organizations to build an outstanding mobile-first website.

Because we believe your website should speak up in your name, we consider our mission completed once your site has become your impresario.

For more info about the man behind the startup, check out my [now page](https://pascalandy.com/blog/now/). You can also follow me on Twitter [@askpascalandy](https://twitter.com/askpascalandy).

— The FirePress Team 🔥📰