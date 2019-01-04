#!/bin/sh

set -e
cat - > /tmp/image
/darknet/darknet $@ /tmp/image
