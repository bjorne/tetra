# Tetra

[![Build Status](https://travis-ci.org/bjorne/tetra.svg?branch=master)](https://travis-ci.org/bjorne/tetra)

![Tetra screenshot](https://cloud.githubusercontent.com/assets/65805/7163057/371f2e3c-e398-11e4-81af-e69e3d16538a.png)

An Amazon S3 client for the terminal.

    $ npm install -g tetra

Features include:

* Curses-like UI with vim bindings for browsing S3 (using [blessed](https://github.com/chjj/blessed))

## Usage

    $ tetra <bucket>

Tetra uses environment variables `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` for enabling access to S3, so ensure these are
set to browse private buckets. Tetra also selects region via
`AWS_DEFAULT_REGION` if set.

## Development

The project is written in CoffeeScript, which resides in `src/`. Files
are compiled to `lib/`. Use `gulp watch` to watch for changes, compile
and run the tests.
