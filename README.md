# jetson-kernel snap

This repository contains the building recipe for a kernel snap for the
Jetson TX1/TX2 devices.

## Build instructions

Depending on your target:

`cd tx1`

or

`cd tx2`

To build the snap, if in the target machine:

`snapcraft`

Otherwise:

`snapcraft --target-arch arm64`
