require 'spec_helper'

describe OmniAuth::Strategies::Exvo do

  attr_accessor :app

  def set_app!
    self.app = Rack::Builder.app do
      use Rack::Session::Cookie
      use OmniAuth::Strategies::Exvo
      run lambda { |env| [200, {'env' => env}, ['Hello!']] }
    end
  end

  subject do
    OmniAuth::Strategies::Exvo.new(nil, @options || {})
  end

  it_should_behave_like 'an oauth2 strategy'

  describe '#client' do
    it 'should have the correct Exvo Auth site' do
      subject.client.site.should eq('https://auth.exvo.com')
    end

    it 'should have the correct authorization url' do
      subject.client.options[:authorize_url].should eq('/oauth/authorize')
    end

    it 'should have the correct token url' do
      subject.client.options[:token_url].should match(/\/oauth\/access_token$/)
    end
  end

  describe '#callback_key' do
    specify { subject.callback_key.should match(/callback/) }
  end

  describe '#callback_path' do
    its(:callback_path) { should eq('/auth/exvo/callback') }
  end

  describe '#callback_url' do
    before do
      subject.request.should_receive(:url).and_return('https://auth.exvo.com')
      subject.should_receive(:script_name).and_return('')
    end

    it 'should have the correct callback url' do
      subject.should_receive(:interactive?).and_return(true)
      subject.callback_url.should eq('https://auth.exvo.com/auth/exvo/callback')
    end

    it 'should include _callback param if it is passed in request' do
      subject.should_receive(:interactive?).and_return(false)
      subject.request.should_receive(:[]).with('_callback').and_return('123')
      subject.callback_url.should eq('https://auth.exvo.com/auth/exvo/callback?_callback=123')
    end
  end

  describe '#interactive? and #non_interactive? return false and true, respectively, if request has callback key' do
    before do
      subject.request.should_receive(:[]).with('_callback').and_return('123')
    end

    it { should_not be_interactive }
    it { should be_non_interactive }
  end

  describe '#uid' do
    it 'returns the uid from raw_info' do
      subject.stub(:raw_info).and_return({ 'id' => '123' })
      subject.uid.should eq('123')
    end
  end

  describe '#info' do
    before :each do
      subject.stub(:raw_info).and_return({ 'id' => '123', 'nickname' => 'Pawel', 'email' => 'some@email.com' })
    end

    it 'returns the nickname' do
      subject.info['nickname'].should eq('Pawel')
    end

    it 'returns the email' do
      subject.info['email'].should eq('some@email.com')
    end
  end

  describe '#extra' do
    let(:extra) { { 'language' => 'en' } }

    it 'returns a hash of extra information' do
      subject.stub(:raw_info).and_return(extra)
      subject.extra.should eq({ :raw_info => extra })
    end
  end

  describe '#credentials' do
    before :each do
      @access_token = double('OAuth2::AccessToken')
      @access_token.stub(:token).and_return('123')
      @access_token.stub(:expires?).and_return(false)
      subject.stub(:access_token).and_return(@access_token)
    end

    specify { subject.credentials.should be_a(Hash) }

    specify { subject.credentials['token'].should eq('123') }

    specify { subject.credentials['expires'].should eq(false) }
  end

  describe '#request_phase' do
    before do
      set_app!
    end

    it 'redirects to auth app with a callback param' do
      get '/auth/exvo'
      last_response.should be_redirect
      follow_redirect!
      last_request.url.should match(/^https:\/\/auth\.exvo\.com\/.+callback$/)
    end

    it 'passes a custom x_sign_up authorize param' do
      get '/auth/exvo?x_sign_up=true'
      last_response.should be_redirect
      follow_redirect!
      last_request.url.should match(/^https:\/\/auth\.exvo\.com\/.+x_sign_up=true$/)
    end
  end

  describe '#set_failure_handler' do
    let(:env) { { 'omniauth.error.type' => 'invalid_credentials', 'SCRIPT_NAME' => 'http://example.com' } }
    let(:failure) { OmniAuth.config.on_failure.call(env) }

    context "interactive" do
      before do
        subject.should_receive(:interactive?).and_return(true)
        subject.set_failure_handler
      end

      it 'sets a redirect Rack response array' do
        failure[0].should eq(302)
        failure[1]['Location'].should match(/^http:\/\/example.com\/auth\/failure/)
      end
    end

    context "non_interactive" do
      before do
        subject.should_receive(:interactive?).and_return(false)
        subject.set_failure_handler
      end

      it 'sets an unauthorized Rack response array' do
        failure[0].should eq(401)
        failure[2][0].should match(/invalid_credentials/)
      end
    end
  end

end
