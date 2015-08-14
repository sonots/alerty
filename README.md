# alerty

A CLI utility to send an alert if a given command failed. 

## How Useful?

I use `alerty` to run commands in cron to send alerts if cron commands fail.

```
0 * * * * alerty -c /etc/sysconfig/alerty -- /path/to/script --foo FOO --bar
```

## Installation

```
gem install alerty
```

## Configuration

You can write a configuration file located at `/etc/sysconfig/alerty` (You can configure this path by `ALERTY_CONFIG_FILE` environment variable, or `-c` option):

```
log_path: STDOUT
log_level: 'debug'
timeout: 10
lock_path: /tmp/lock
plugins:
  - type: stdout
```

[example/alerty.yml](./example/alerty.yml)

### CLI Example

```
$ alerty -c example.yml -- ls -l /something_not_exist
```

### CLI Help

```
$ bin/alerty -h
    -c, --config CONFIG_FILE         config file path (default: /etc/sysconfig/alerty)
        --log LOG_FILE               log file path (default: STDOUT)
        --log-level LOG_LEVEL        log level (default: warn
    -t, --timeout SECONDS            timeout the command (default: no timeout)
    -l, --lock LOCK_FILE             exclusive lock file to prevent running a command duplicatedly (default: no lock)
```

## Plugins

Following plugins are available:

* [stdout](./lib/alerty/plugin/stdout.rb)
* [file](./lib/alerty/plugin/file.rb)
* [exec](./lib/alerty/plugin/exec.rb)
* [alerty-plugin-ikachan](https://github.com/sonots/alerty-plugin-ikachan)
* [alerty-plugin-amazon_sns](https://github.com/sonots/alerty-plugin-amazon_sns)

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

### Licenses

See [LICENSE](LICENSE)
