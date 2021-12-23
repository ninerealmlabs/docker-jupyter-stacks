# Notes

## 28 June 2021

- Pausing development on CI pipeline due to hitting limit on shared storage
- `workflow_run` works to call workflows from other workflows
- Current sticking point is that images cannot be passed between workflows
  - this is required for `workflow_run` splitting of docker-ci.yml
  - also required to split CI from CD / push to registries
- _Solution???_: github registry (ghcr.io) to hold images during CI process?

## 4 July 2021

- CI works, but use of _current_ git sha in BASE_IMAGE arg means that workflows
  will error out if a new commit is made while builds are in progress
- `web_env` and `forecast_env` limited to python [3.7, 3.8] (dependency conflicts with 3.9)
