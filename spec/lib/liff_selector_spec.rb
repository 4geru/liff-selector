require "spec_helper"
require './lib/liff_selector'
require 'webmock'
 
WebMock.enable! 
 

describe LiffSelector do
  let(:request_url){ 'https://api.line.me/liff/v1/apps' }
  let(:app){ {liffId: 'LIFF_ID', view: {type: 'TYPE', url: 'URL'}}}
  let(:apps){ {apps: [app] } }
  context 'unknown command' do
    subject{ LiffSelector.run(['unknown']) }
    it { expect{subject}.to raise_error(NotImplementedError) }
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
end