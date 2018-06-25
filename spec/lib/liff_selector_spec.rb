require "spec_helper"
require './lib/liff_selector'
require 'webmock'
 
WebMock.enable! 
 

describe LiffSelector do
  let(:request_url){ 'https://api.line.me/liff/v1/apps' }
  let(:app){ JSON.parse({liffId: 'LIFF_ID', view:{type: 'TYPE', url: 'URL'}}.to_json) }
  let(:apps){ {apps: [app] } }
  context 'unknown command' do
    subject{ LiffSelector.run(['unknown']) }
    it { expect{subject}.to raise_error(NotImplementedError) }
  end

  describe '#show' do
    subject{ LiffSelector.show }
    before do
      allow(LiffSelector).to receive(:all_apps).and_return( [app] )
    end
    context 'app count' do
      it { expect { subject }.to output(/1. #{app['liffId']}\t#{app['view']['type']}\t#{app['view']['url']}/).to_stdout }
    end
  end

  describe '#all_apps' do
    subject{ LiffSelector.all_apps }
    before do
      # GETリクエストのスタブ登録
      WebMock.stub_request(:get, request_url).to_return(
        body: apps.to_json,
        status: 200,
        headers: { 'bearer' =>  ENV['LINE_TOKEN']})
    end
    context 'app count' do
      it { expect(subject.length).to eq 1 }
    end
    context 'not stdout' do
      it { expect{ subject }.to_not output.to_stdout }
    end
  end

  describe '#help' do
    subject{ LiffSelector.help }
    it { expect { subject }.to output(/show/).to_stdout }
    it { expect { subject }.to output(/same/).to_stdout }
    it { expect { subject }.to output(/clean/).to_stdout }
    it { expect { subject }.to output(/upload/).to_stdout }
    it { expect { subject }.to output(/delete/).to_stdout }
    it { expect { subject }.to output(/help/).to_stdout }
    it { expect { subject }.to output(/new/).to_stdout }
    it { expect { subject }.to output(/liff_select/).to_stdout }
  end

  describe '#upload' do
    context 'argument error' do
      it { expect{LiffSelector.run(['upload'])}.to raise_error(ArgumentError) }
      it { expect{LiffSelector.run(['upload', 'compact'])}.to raise_error(ArgumentError) }
      it { expect{LiffSelector.upload(type: 'hoge' ,url: 'https://example.com') }.to raise_error(ArgumentError) }
    end

    context 'upload' do
      subject{ LiffSelector.upload(type: 'compact' ,url: 'https://example.com') }
      before do
        # GETリクエストのスタブ登録
        WebMock.stub_request(:post, request_url).to_return(
          body: {liffId: 'LIFF_ID'}.to_json,
          status: 200,
          headers: { 'bearer' =>  ENV['LINE_TOKEN']})
      end
      it { expect { subject }.to output(/SUCCESS/).to_stdout }
      it { expect { subject }.to output(/app uri : line:\/\/app\/LIFF_ID/).to_stdout }
    end
  end

  describe '#same' do
    # TODO
  end

  describe '#create' do
    # TODO
  end

  describe '#clean' do
    # TODO
  end

  describe '#delete' do
    # TODO
  end
end