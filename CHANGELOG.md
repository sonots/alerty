# 0.2.2 (2017/01/20)

Fixes:

* Fix log_shift_age and log_shift_size config were not working (instead, shift_age and shift_size were working)

# 0.2.1 (2016/09/25)

Enhancements:

* Add --dotenv option to load environment variables from .env file

# 0.2.0 (2016/09/25)

Enhancements:

* Allow erb in config yaml

# 0.1.1 (2016/09/05)

Enhancements:

* Bundler.with_clean_env

# 0.1.0 (2016/03/28)

Enhancements:

* Add --log-shift-age option
* Add --log-shift-size option

# 0.0.9 (2015/11/23)

Enhancements:

* Support retry

# 0.0.8 (2015/08/15)

Enhancements:

* Send alert if timeout or locked occurs

# 0.0.7 (2015/08/15)

Enhancements:

* Change -l option from --lock to --log-level
* Add -d (--debug) option, same with -l debug

# 0.0.6 (2015/08/14)

Enhancements:

* Add info log to show command result

# 0.0.5 (2015/08/14)

Changes:

* Change default conf path from /etc/sysconfig/alerty to /etc/alerty/alerty.yml

# 0.0.4 (2015/08/14)

Enchancements:

* Add exec plugin
* Pass `hostname` to plugins

# 0.0.3 (2015/08/14)

Enchancements:

* Pass more information to plugins
  * command
  * exitstatus
  * output
  * started_at
  * duration

# 0.0.2 (2015/08/13)

Enchancements:

* Allow to configure timeout and lock_path in config file (options outcome)
* Allow to configure log_path and log_level as command options (options outcome)

# 0.0.1 (2015/08/13)

first version
