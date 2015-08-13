require 'spec_helper'

describe Alerty::Config do
  describe 'configure' do
    before do
      Alerty::Config.configure(
        log_path: '/tmp/foo',
        log_level: 'fatal',
        timeout: 20,
        lock_path: '/tmp/lock',
      )
    end

    it { expect(Alerty::Config.log_path).to eql('/tmp/foo') }
    it { expect(Alerty::Config.log_level).to eql('fatal') }
    it { expect(Alerty::Config.timeout).to eql(20) }
    it { expect(Alerty::Config.lock_path).to eql('/tmp/lock') }
  end

  describe 'config' do
    before do
      Alerty::Config.instance_variable_set(:@config, Hashie::Mash.new(
        log_path: '/tmp/foo',
        log_level: 'fatal',
        timeout: 20,
        lock_path: '/tmp/lock',
      ))
    end

    it { expect(Alerty::Config.log_path).to eql('/tmp/foo') }
    it { expect(Alerty::Config.log_level).to eql('fatal') }
    it { expect(Alerty::Config.timeout).to eql(20) }
    it { expect(Alerty::Config.lock_path).to eql('/tmp/lock') }
  end

  describe 'plugins' do
    before do
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
