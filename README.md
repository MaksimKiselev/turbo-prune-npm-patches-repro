# turbo prune drops npm 12 patches

npm 12 can patch dependencies (`npm patch`). `turbo prune --docker` doesn't carry
those patches over, so `npm ci` fails in the pruned output.

So any npm 12 monorepo that uses `npm patch` can't follow the Turborepo Docker guide:
the install step fails, and the only workaround is copying `patches/` and editing
`package.json` by hand. pnpm and Yarn patches already work.

Tested with turbo 2.11.7 and 2.11.5-canary.5, npm 12.2.0, node 24.

## What's in here

Two apps and one patch:

- `apps/web` depends on `is-number`, which is patched. It prints whether the patch
  was applied.
- `apps/docs` depends on `ms`. It has nothing to do with the patch.

## Try it

```sh
docker build --build-arg APP=web .
docker build --build-arg APP=docs .
```

The Dockerfile is a trimmed version of the multi-stage build in the
[Turborepo Docker guide](https://turborepo.com/docs/guides/tools/docker).

## What should happen

`out/json` contains the patch files the pruned lockfile uses, and
`patchedDependencies` lists only those. Both builds pass; `web` prints
`is-number is patched`.

## What happens

Both builds fail on `npm ci`.

**`web`**: the patch file isn't copied into `out/json`. The pruned lockfile still
references it correctly.

```
npm error code EPATCHNOTFOUND
npm error patch file not found: patches/is-number@7.0.0.patch
```

**`docs`**: the patch is still listed in `out/json/package.json`, even though
`is-number` isn't in the pruned lockfile. `npm ci` doesn't allow skipping this.

```
npm error code EPATCHUNUSED
npm error The following patches were registered but matched no installed package:
npm error   is-number@7.0.0 -> patches/is-number@7.0.0.patch
```
