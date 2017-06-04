require 'spec_helper'

describe Overcommit::Hook::PreCommit::Pycodestyle do
  let(:config)  { Overcommit::ConfigurationLoader.default_configuration }
  let(:context) { double('context') }
  subject { described_class.new(config, context) }

  before do
    subject.stub(:applicable_files).and_return(%w[file1.py file2.py])
  end

  context 'when pycodestyle exits successfully' do
    before do
      result = double('result')
      result.stub(success?: true, stdout: '')
      subject.stub(:execute).and_return(result)
    end

    it { should pass }
  end

  context 'when pycodestyle exits unsucessfully' do
    let(:result) { double('result') }

    before do
      result.stub(:success?).and_return(false)
      subject.stub(:execute).and_return(result)
    end

    context 'and it reports a warning' do
      before do
        result.stub(:stdout).and_return([
          'file1.py:1:1: W391 blank line at end of file'
        ].join("\n"))
      end

      it { should warn }
    end

    context 'and it reports an error' do
      before do
        result.stub(:stdout).and_return([
          'file1.py:1:80: E501 line too long (80 > 79 characters)'
        ].join("\n"))
      end

      it { should fail_hook }
    end
  end
end
