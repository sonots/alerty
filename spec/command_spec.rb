require 'spec_helper'

describe Alerty::Command do
  describe 'run' do
    context 'Frontkick.exec' do
      before do
        Alerty::Config.configure(
          log_path: '/tmp/foo',
          log_level: 'fatal',
          timeout: 20,
          lock_path: '/tmp/lock',
          config_path: File.join(ROOT, 'spec/cli_spec.yml'),
        )
      end

      let(:command) { Alerty::Command.new(command: 'ls') }

      it do
        expect(Frontkick).to receive(:exec).with("ls", {
          timeout: 20,
          exclusive: '/tmp/lock',
          popen2e: true,
        }).and_return(Frontkick::Result.new(exit_code: 0))
        command.run
      end
    end

    context 'plugins.alert' do
      before do
        Alerty::Config.instance_variable_set(:@config, Hashie::Mash.new(
          plugins: [{
            type: 'stdout',
          }]
        ))
        Alerty::Config.configure(
          log_path: '/tmp/foo',
          log_level: 'fatal',
          timeout: nil,
          lock_path: nil,
        )
      end

      let(:command) { Alerty::Command.new(command: 'echo foo') }

      it do
        expect(Frontkick).to receive(:exec).with("echo foo", {
          timeout: nil,
          exclusive: nil,
          popen2e: true,
        }).and_return(Frontkick::Result.new(stdout: 'foo', exit_code: 1))
        record = command.run
        expect(record[:output]).to eql("foo")
      end
    end

    context 'timeout' do
      before do
        Alerty::Config.instance_variable_set(:@config, Hashie::Mash.new(
          plugins: [{
            type: 'stdout',
          }]
        ))
        Alerty::Config.configure(
          log_path: '/tmp/foo',
          log_level: 'fatal',
          timeout: 0.1,
          lock_path: '/tmp/lock',
        )
      end

      let(:command) { Alerty::Command.new(command: 'sleep 1') }

      it do
        expect(Frontkick).to receive(:exec).with("sleep 1", {
          timeout: 0.1,
          exclusive: '/tmp/lock',
          popen2e: true,
        }).and_raise(Frontkick::Timeout.new(111, 'sleep 1', true))
        record = command.run
        expect(record[:output]).to include("timeout")
      end
    end

    context 'lock' do
      before do
        Alerty::Config.instance_variable_set(:@config, Hashie::Mash.new(
          plugins: [{
            type: 'stdout',
          }]
        ))
        Alerty::Config.configure(
          log_path: '/tmp/foo',
          log_level: 'fatal',
          timeout: 20,
          lock_path: '/tmp/lock',
        )
      end

      let(:command) { Alerty::Command.new(command: 'sleep 1') }

      it do
        expect(Frontkick).to receive(:exec).with("sleep 1", {
          timeout: 20,
          exclusive: '/tmp/lock',
          popen2e: true,
        }).and_raise(Frontkick::Locked)
        record = command.run
        expect(record[:output]).to include("lock")
      end
    end

    context 'retry' do
      before do
        Alerty::Config.instance_variable_set(:@config, Hashie::Mash.new(
          plugins: [{
            type: 'stdout',
          }]
        ))
        Alerty::Config.configure(
          log_path: '/tmp/foo',
          log_level: 'fatal',
          retry_limit: 1,
        )
      end

      let(:command) { Alerty::Command.new(command: 'echo foo') }

      it do
        expect(Frontkick).to receive(:exec).twice.with("echo foo", {
          timeout: nil,
          exclusive: nil,
          popen2e: true,
        }).and_return(Frontkick::Result.new(stdout: 'foo', exit_code: 1))
        record = command.run
        expect(record[:retries]).to eql(1)
      end
    end

  end
end
