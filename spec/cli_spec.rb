require 'spec_helper'
require 'fileutils'

describe Alerty::CLI do
  CONFIG_PATH = File.join(File.dirname(__FILE__), 'cli_spec.yml')
  BIN_DIR = File.join(ROOT, 'bin')
  OUTPUT_FILE = File.join(File.dirname(__FILE__), 'cli_spec.out')

  describe '#parse_options' do
    it 'incorrect' do
      expect { Alerty::CLI.new.parse_options([]) }.to raise_error(OptionParser::InvalidOption)
    end

    it 'command' do
      expect(Alerty::CLI.new.parse_options(['--', 'ls', '-l'])[:command]).to eql('ls -l')
    end

    it 'config' do
      expect(Alerty::CLI.new.parse_options(['-c', 'config.yml', '--', 'ls'])[:config_path]).to eql('config.yml')
    end
  end

  describe '#run' do
    context 'with success' do
      before :all do
        FileUtils.rm(OUTPUT_FILE, force: true)
        system("#{File.join(BIN_DIR, 'alerty')} -c #{CONFIG_PATH} -- echo foo")
        sleep 0.1
      end

      it 'should not output' do
        expect(File.size?(OUTPUT_FILE)).to be_falsey
      end
    end

    context 'with failure' do
      before :all do
        FileUtils.rm(OUTPUT_FILE, force: true)
        system("#{File.join(BIN_DIR, 'alerty')} -c #{CONFIG_PATH} -- [ a = b ]")
        sleep 0.1
      end

      it 'should output' do
        expect(File.size?(OUTPUT_FILE)).to be_truthy
      end
    end
  end
end
