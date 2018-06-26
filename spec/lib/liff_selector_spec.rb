require "spec_helper"
require './lib/liff_selector'
require 'webmock'
 
WebMock.enable! 
 

describe LiffSelector do
  let(:request_url){ 'https://api.line.me/liff/v1/apps' }
  let(:app){ JSON.parse({liffId: 'LIFF_ID', view:{type: 'TYPE', url: 'URL'}}.to_json) }
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
      WebMock.stub_request(:get, request_url).to_return(
        body: {apps: [app]}.to_json,
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
    subject{ LiffSelector.upload(type: 'compact' ,url: 'https://example.com') }
    before do
      WebMock.stub_request(:post, request_url).to_return(
        body: {liffId: 'LIFF_ID'}.to_json,
        status: 200,
        headers: { 'bearer' =>  ENV['LINE_TOKEN']})
    end
    it { expect { subject }.to output(/[SUCCESS]/).to_stdout }
    it { expect { subject }.to output(/app uri : line:\/\/app\/LIFF_ID/).to_stdout }
  end

  describe '#same' do
    subject{ LiffSelector.same }
    before do
      # GETリクエストのスタブ登録
      WebMock.stub_request(:get, request_url).to_return(
        body: {apps: [app, app]}.to_json,
        status: 200,
        headers: { 'bearer' =>  ENV['LINE_TOKEN']})
    end

    it { expect { subject }.to output(/- id:/).to_stdout }
    it { expect { subject }.to output(/> "type": TYPE, "url": URL/).to_stdout }
  end

  describe '#create' do
    subject{ LiffSelector.create(file_name: 'FILENAME') }
    before do
      allow(File).to receive(:read).and_return( nil )
      allow(File).to receive(:join).and_return( nil )
      allow(File).to receive(:dirname).and_return( nil )
      allow(File).to receive(:write).and_return( nil )
    end

    it { expect { subject }.to output(/[SUCCESS]/).to_stdout }
    it { expect { subject }.to output(/FILENAME.html/).to_stdout }
  end

  describe '#clean' do
    context 'not same app' do
      before do
        allow(LiffSelector).to receive(:same).and_return([])
      end
      it { expect { LiffSelector.clean }.to raise_error(ArgumentError) }
    end

    context 'sccess' do
      before do
        allow(LiffSelector).to receive(:same).and_return([app])
        WebMock.stub_request(:delete, "#{request_url}/#{app['liffId']}").to_return(
          status: 200,
          headers: { 'bearer' =>  ENV['LINE_TOKEN']})
      end
      it { expect { LiffSelector.clean }.to output(/[SUCESS]/).to_stdout }
    end
  end

  describe '#delete' do
    subject { LiffSelector.delete(liff_id: 1) }
    context 'success' do
      before do
        allow(LiffSelector).to receive(:all_apps).and_return( [app] )
      end
      it { expect { subject }.to output(/[SUCESS]/).to_stdout }
      it { expect { subject }.to output(/#{app['liffId']}/).to_stdout }
      it { expect { subject }.to output(/#{app['view']['type']}/).to_stdout }
      it { expect { subject }.to output(/#{app['view']['url']}/).to_stdout }
    end
  end
end