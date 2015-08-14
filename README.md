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

## Plugin Architecture

### Naming Convention

You must follow the below naming conventions:

* gem name: alerty-plugin-xxx (xxx_yyy)
* file name: lib/alerty/plugin/xxx.rb (xxx_yyy.rb)
* class name: Alerty::Plugin:Xxx (XxxYyy)

### Interface

What you have to implement is `#initialize` and `#alert` methods. Here is an example of `file` plugin:

```ruby
require 'json'

class Alerty
  class Plugin
    class File
      def initialize(config)
        raise ConfigError.new('file: path is not configured') unless config.path
        @path = config.path
      end

      def alert(record)
        ::File.open(@path, 'a') do |io|
          io.puts record.to_json
        end
      end
    end
  end
end
```

### config

`config` is created from the configuration file: 

```
plugins:
  - type: foobar
    key1: val1
    key2: val2
```

`config.key1` and `config.key2` are availabe in the above config. 

### record

`record` is a hash whose keys are

* hostname: hostname
* command: the executed command
* exitstatus: the exit status of the executed command
* output: the output of the exectued command
* started_at: the time when command executed in epoch time.
* duration: the duration which the command execution has taken in seconds. 

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

### Licenses

See [LICENSE](LICENSE)
