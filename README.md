WordPress+Piwik deploy recipe for *ellakcy*, forked from
[github.com/indiehosters/piwik](https://github.com/indiehosters/piwik).

##Installation
Just run on your command line:

```````
cd ^path that you cloned your project^
./scripts/install.sh

```````

After that you can start the piwik and wordpress services via:

``````
./start.sh

``````

And you stop with:

``````
./stop.sh

``````

Also you can perform a backup by running (for now does not work to be improved):

```
./backup.sh
```

## Migrating from previous installation

Just run:

```
cd ^path that you cloned your project^
./scripts/migrate_to_env_file.sh
```
