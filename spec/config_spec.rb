require 'spec_helper'

describe Alerty::Config do
  describe 'configure' do
    before do
      Alerty::Config.configure(
        log_path: '/tmp/foo',
        log_level: 'fatal',
        timeout: 20,
        lock_path: '/tmp/lock',
        retry_limit: 5,
        retry_wait: 10,
      )
    end

    it { expect(Alerty::Config.log_path).to eql('/tmp/foo') }
    it { expect(Alerty::Config.log_level).to eql('fatal') }
    it { expect(Alerty::Config.timeout).to eql(20) }
    it { expect(Alerty::Config.lock_path).to eql('/tmp/lock') }
    it { expect(Alerty::Config.retry_limit).to eql(5) }
    it { expect(Alerty::Config.retry_wait).to eql(10) }
  end

  describe 'config' do
    before do
      Alerty::Config.instance_variable_set(:@config, Hashie::Mash.new(
        log_path: '/tmp/foo',
        log_level: 'fatal',
        timeout: 20,
        lock_path: '/tmp/lock',
        retry_limit: 5,
        retry_wait: 10,
      ))
    end

    it { expect(Alerty::Config.log_path).to eql('/tmp/foo') }
    it { expect(Alerty::Config.log_level).to eql('fatal') }
    it { expect(Alerty::Config.timeout).to eql(20) }
    it { expect(Alerty::Config.lock_path).to eql('/tmp/lock') }
    it { expect(Alerty::Config.retry_limit).to eql(5) }
    it { expect(Alerty::Config.retry_wait).to eql(10) }
  end

  describe '#retry_interval' do
    before do
      Alerty::Config.configure(
        retry_wait: 10,
      )
    end

    it do
      # retry_wait +/- 12.5% randomness
      expect(Alerty::Config.retry_interval).to be >= 10 - 1.25
      expect(Alerty::Config.retry_interval).to be <= 10 + 1.25
    end
  end

  describe 'plugins' do
    before do
      Alerty::Config.reset
      Alerty::Config.instance_variable_set(:@config, Hashie::Mash.new(
        log_path: '/tmp/foo',
        log_level: 'fatal',
        timeout: 20,
        lock_path: '/tmp/lock',
        plugins: [
          {
            type: 'stdout',
          },
          {
            type: 'file',
            path: 'STDOUT',
          }
        ]
      ))
    end

    it do
      expect(Alerty::Config.plugins[0]).to be_a(Alerty::Plugin::Stdout)
      expect(Alerty::Config.plugins[1]).to be_a(Alerty::Plugin::File)
    end
  end
end
