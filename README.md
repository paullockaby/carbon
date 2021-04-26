# carbon
This container runs the [carbon](https://github.com/graphite-project/carbon)
daemon and that's it.

## Running on Docker

This volume expects to listen on two ports and have two mounted volumes. It
needs to listen on port 2003 TCP, 2004 TCP, and 7002 TCP. It needs to have
`/opt/graphite/conf` and `/opt/graphite/storage` mounted.

    docker build -t ghcr.io/paullockaby/carbon:latest .
    docker run --rm -it -p 2003:2003/tcp -p 2004:2004/tcp -p 7002:7002/tcp -v $PWD/storage:/opt/graphite/storage -v $PWD/example:/opt/graphite/conf ghcr.io/paullockaby/carbon:latest

Alternatively you can use the Makefile to do builds and run the tool all in one
step:

    make run

An example configuration file is in the `example` directory.
