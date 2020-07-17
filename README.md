# mvps-darch-bootstrap
Scripts for bootstrapping a [Darch](godarch.com) setup on [mvps.net](mvps.net) servers.

I've had some issues setting up a workable Darch setup on MVPS servers because they have a very small disk that is not easily partitionable.
This script uses the swap space to create a new rootdisk of 8GB instead of the starting 20GB. After that, darch is installed and set up.

Simply run `mvps_bootstrap.sh 1.2.3.4` on a newly booted Debian server and wait for a minute or two.
