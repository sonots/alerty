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
        expect { command.run! }.to raise_error(SystemExit)
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
        expect(stdout).to eql("foo\n")
      end
    end
  end
end