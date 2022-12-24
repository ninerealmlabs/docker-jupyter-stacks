# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project itself does not use semantic versioning because the versions
of its dependencies (python, jupyterlab, numpy, etc.) are more critical to track
thank the particular buid.

## [Unreleased]

### Added

- tests

### Changed

### Deprecated

### Removed

### Fixed

## 2022-12-24

### Changed

- updated ci/cd workflows for more consistent/regular builds
- renamed images `base_env` --> `base-env`
- renamed `forecast_env` --> `ts-env`
- `web-env` now based on `nlp-env`

### Removed

- pytorch_env
