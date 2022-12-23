# Github CI/CD

- [Github CI/CD](#github-cicd)
  - [Overview](#overview)
    - [build-stack](#build-stack)
    - [image-dependencies](#image-dependencies)
    - [build-test-tag](#build-test-tag)
  - [Actions](#actions)
    - [build-image-action](#build-image-action)
    - [test-image-action](#test-image-action)
  - [References](#references)

## Overview

The  main CI/CD pipeline nests reusable workflows 3 layers deep:

```txt
1-build-stack.yaml
  └ 2-image-dependencies.yaml
      └ 3-build-test-tag.yaml
```

> For a less-nested CI/CD pipeline, check out the [prior version](https://github.com/ninerealmlabs/docker-jupyter-stacks/commit/a9f33274b46c71bdf2266a0f1b14151fa8b8dbe8),
> which uses a (relatively boilerplate) template per image environment

`pre-commit.yaml` runs pre-commit checks to help ensure code quality.
`hub-overview.yaml` pushes repo descriptions

### build-stack

This outermost workflow acts as the primary trigger for the pipeline,
exposes 'static' environment variables to subsequent reusable workflows [ref](https://github.com/orgs/community/discussions/26671#discussioncomment-4295807),
and sets up the loop to build the stack for each version of python

### image-dependencies

This workflow handles the dependencies between images.

> If image dependencies change, they must be reflected in:
>
> - [./README.md (at repo root)](./README.md)
> - [./scripts/dependencies.txt](./scripts/dependencies.txt)
> - [./tests/images-hierarcy.py](./tests/images-hierarcy.py)
> - [./.github/workflows/2-image-dependencies.yaml](./.github/workflows/2-image-dependencies.yaml)
> - [./.github/workflows/hub-overview.yaml](./.github/workflows/hub-overview.yaml)

### build-test-tag

This workflow acts as a runner for the 3-step build process, calling local [`composite actions`](./.github/actions/),
and other build steps

## Actions

### build-image-action

This composite action handles the various intricacies of using `docker buildx` for multi-architecture images,
and returns relevant tags, name:tags, and image digest as outputs.

### test-image-action

This composite action runs unit tests copied (essentially unchanged) from [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks)

## References

- ['Workflows' defined inside `jobs`; 'Actions' defined inside `steps`](https://github.com/actions/checkout/issues/692#issuecomment-1259789797)
- [Reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Actions](https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions#runs-for-composite-actions)
