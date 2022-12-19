# Github CI/CD

- [Github CI/CD](#github-cicd)
  - [Overview](#overview)
    - [workflow-runner](#workflow-runner)
    - [build-stack](#build-stack)
    - [build-test-tag](#build-test-tag)
    - [build-image](#build-image)
    - [test-image](#test-image)
    - [tag image](#tag-image)
  - [References](#references)

## Overview

This CI/CD pipeline nests reusable workflows 4 layers deep:

```txt
./workflows/workflow-runner.yaml
  └ ./workflows/1-jobs/build-stack.yaml
      └ ./workflows/2-steps/build-test-tag.yaml
          ├ ./workflows/3-tasks/build-image.yaml
          ├ ./workflows/3-tasks/test-image.yaml
          └ ./workflows/3-tasks/tag-image.yaml
```

> For a less-nested CI/CD pipeline, check out the [prior version](https://github.com/ninerealmlabs/docker-jupyter-stacks/commit/a9f33274b46c71bdf2266a0f1b14151fa8b8dbe8),
> which uses a (relatively boilerplate) template per image environment

### workflow-runner

This outermost workflow acts as the primary trigger for the pipeline,
exposes 'static' environment variables to subsequent reusable workflows [ref](https://github.com/orgs/community/discussions/26671#discussioncomment-4295807),
and sets up the loop to build the stack for each version of python

### build-stack

This workflow handles the dependencies between images.

> If image dependencies change, they must be reflected in:
>
> - [./README.md (at repo root)](./README.md)
> - [./scripts/dependencies.txt](./scripts/dependencies.txt)
> - [./tests/images-hierarcy.py](./tests/images-hierarcy.py)
> - [./.github/workflows/1-jobs/build-stack.yaml](./.github/workflows/1-jobs/build-stack.yaml)

### build-test-tag

This workflow acts as a runner for the 3-step build process, calling build, test, and tag workflows.

`build-test-tag` gets the built image digest from `build-image` and returns it as an output for use in `build-stack`

### build-image

This workflow handles the various intricacies of using `docker buildx` for multi-architecture images,
and returns relevant tags, name:tags, and image digest as outputs.

### test-image

This workflow runs unit tests copied (essentially unchanged) from [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks)

### tag image

If all prior steps succeed and the pipeline is running in the `main` branch,
this workflow will pull the images cached from the ghcr.io,
retag, and push them to docker.io (or quay.io)

## References

- [Reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
