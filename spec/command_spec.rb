require 'spec_helper'

describe Alerty::Command do
  describe 'run!' do
    context 'Frontkick.exec' do
      before do
        Alerty::Config.configure(
          log_path: '/tmp/foo',
          log_level: 'fatal',
          timeout: 20,
          lock_path: '/tmp/lock',
        )
      end

      let(:command) { Alerty::Command.new(command: 'ls') }

      it do
        expect(Frontkick).to receive(:exec).with("ls 2>&1", {
          timeout: 20,
          exclusive: '/tmp/lock',
        }).and_return(Frontkick::Result.new(exit_code: 0))
        expect { command.run! }.not_to raise_error
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
        expect(Frontkick).to receive(:exec).with("echo foo 2>&1", {
          timeout: nil,
          exclusive: nil,
        }).and_return(Frontkick::Result.new(stdout: 'foo', exit_code: 1))
        stdout = capture_stdout { expect { command.run! }.to raise_error(SystemExit) }
        expect(JSON.parse(stdout)["output"]).to eql("foo")
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
        expect(Frontkick).to receive(:exec).with("sleep 1 2>&1", {
          timeout: 0.1,
          exclusive: '/tmp/lock',
        }).and_raise(Frontkick::Timeout.new(111, 'sleep 1 2>&1', true))
        stdout = capture_stdout { expect { command.run! }.to raise_error(SystemExit) }
        expect(JSON.parse(stdout)["output"]).to include("timeout")
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
        expect(Frontkick).to receive(:exec).with("sleep 1 2>&1", {
          timeout: 20,
          exclusive: '/tmp/lock',
        }).and_raise(Frontkick::Locked)
        stdout = capture_stdout { expect { command.run! }.to raise_error(SystemExit) }
        expect(JSON.parse(stdout)["output"]).to include("lock")
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
        expect(Frontkick).to receive(:exec).twice.with("echo foo 2>&1", {
          timeout: nil,
          exclusive: nil,
        }).and_return(Frontkick::Result.new(stdout: 'foo', exit_code: 1))
        stdout = capture_stdout { expect { command.run! }.to raise_error(SystemExit) }
        expect(JSON.parse(stdout)["retries"]).to eql(1)
      end
    end

  end
end
