require "spec_helper"

describe DwollaV2::Client do
  let!(:id) { "id" }
  let!(:secret) { "secret" }
  let(:token) {{
    :access_token => "9JgZGdKChHhZHcTV7SGSm3bLS3vRpzruZxYA2DQdDSdhgezyKq",
    :refresh_token => "QfcxbZP4CTxw7gC5aQZgMQnH6zwQpgJr9NtQmXaSv5tk5CYEEp",
    :expires_at => "2021-08-05T21:00:27Z",
  }}

  it "::ENVIRONMENTS" do
    expect(DwollaV2::Client::ENVIRONMENTS).to eq({
      :production => {
        :auth_url  => "https://accounts.dwolla.com/auth",
        :token_url => "https://api.dwolla.com/token",
        :api_url   => "https://api.dwolla.com"
      },
      :sandbox => {
        :auth_url  => "https://accounts-sandbox.dwolla.com/auth",
        :token_url => "https://api-sandbox.dwolla.com/token",
        :api_url   => "https://api-sandbox.dwolla.com"
      }
    })
  end

  it "#initialize raises ArgumentError if no id" do
    expect {
      DwollaV2::Client.new :secret => secret
    }.to raise_error {|e|
      expect(e).to be_a ArgumentError
      expect(e.message).to eq ":key is required"
    }
  end

  it "#initialize raises ArgumentError if no secret" do
    expect {
      DwollaV2::Client.new :id => id
    }.to raise_error {|e|
      expect(e).to be_a ArgumentError
      expect(e.message).to eq ":secret is required"
    }
  end

  it "#initialize sets id" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.id).to eq id
  end

  it "#initialize sets id if key provided" do
    client = DwollaV2::Client.new :key => id, :secret => secret
    expect(client.id).to eq id
  end

  it "#initialize sets secret" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.secret).to eq secret
  end

  it "#initialize sets token if provided" do
    client = DwollaV2::Client.new(
      :id => id,
      :secret => secret,
      :token => token,
    )
    t = Time.new(2021, 8, 5, 12, 0, 0, "+00:00")
    Timecop.freeze(t) do
      expect(client.current_token.access_token).to eq token[:access_token]
      expect(client.current_token.refresh_token).to eq token[:refresh_token]
      expect(client.current_token.expires_at).to eq Time.iso8601(token[:expires_at])
    end
  end

  it "#initialize yields block" do
    james_bond = spy "007"
    block = Proc.new {|c| james_bond.call(c) }
    client = DwollaV2::Client.new :id => id, :secret => secret, &block
    expect(james_bond).to have_received(:call).with(client)
  end

  it '#initialize sets auths' do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.auths).to be_a DwollaV2::Portal
    expect(client.auths.instance_variable_get :@parent).to be client
    expect(client.auths.instance_variable_get :@klass).to be DwollaV2::Auth
  end

  it '#initialize sets tokens' do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.tokens).to be_a DwollaV2::Portal
    expect(client.tokens.instance_variable_get :@parent).to be client
    expect(client.tokens.instance_variable_get :@klass).to be DwollaV2::Token
  end

  it '#initialize sets environment' do
    client = DwollaV2::Client.new :id => id, :secret => secret, :environment => :sandbox
    expect(client.environment).to be :sandbox
  end

  it "#environment=" do
    client = DwollaV2::Client.new(:id => id, :secret => secret) {|c| c.environment = :sandbox }
    expect(client.environment).to eq :sandbox
  end

  it "#environment= accepts string" do
    client = DwollaV2::Client.new(:id => id, :secret => secret) {|c| c.environment = "sandbox" }
    expect(client.environment).to eq :sandbox
  end

  it "#environment= raises ArgumentError if invalid environment" do
    expect {
      DwollaV2::Client.new(:id => id, :secret => secret) {|c| c.environment = :invalid }
    }.to raise_error {|e|
      expect(e).to be_a ArgumentError
      expect(e.message).to eq "invalid environment"
    }
  end

  it "#environment with arg" do
    client = DwollaV2::Client.new(:id => id, :secret => secret) {|c| c.environment :sandbox }
    expect(client.environment).to eq :sandbox
  end

  it "#environment" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.environment).to eq :production
  end

  it "#on_grant with block" do
    callback = Proc.new {}
    client = DwollaV2::Client.new(:id => id, :secret => secret) {|c| c.on_grant &callback }
    expect(client.on_grant).to eq callback
  end

  it "#on_grant" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.on_grant).to be nil
  end

  it "#faraday with block" do
    block = Proc.new {}
    client = DwollaV2::Client.new(:id => id, :secret => secret) {|c| c.faraday &block }
    expect(client.faraday).to be block
  end

  it "#faraday" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.faraday).to be nil
  end

  it "#conn" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.conn).to be_a Faraday::Connection
    expect(client.conn).to be client.conn
  end

  it "#conn with faraday" do
    james_bond = spy "007"
    block = Proc.new {|a| james_bond.call(a) }
    client = DwollaV2::Client.new(:id => id, :secret => secret) {|c| c.faraday &block }
    expect(james_bond).to have_received(:call).with(client.conn)
  end

  it "#id" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.id).to be id
  end

  it "#key" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.key).to be id
  end

  it "#secret" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.secret).to be secret
  end

  it "#auth_url" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.auth_url).to eq DwollaV2::Client::ENVIRONMENTS[client.environment][:auth_url]
  end

  it "#token_url" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.token_url).to eq DwollaV2::Client::ENVIRONMENTS[client.environment][:token_url]
  end

  it "#api_url" do
    client = DwollaV2::Client.new :id => id, :secret => secret
    expect(client.api_url).to eq DwollaV2::Client::ENVIRONMENTS[client.environment][:api_url]
  end

  describe "token management" do
    let!(:client) { DwollaV2::Client.new(key: "key", secret: "secret") }
    let!(:new_access_token) { "new_access_token" }
    let!(:expires_in) { 3_600 }

    before(:each) do
      stub_request(:post, client.token_url)
          .with(:basic_auth => [client.id, client.secret],
                :headers => {"Content-Type" => "application/x-www-form-urlencoded"},
                :body => {"grant_type" => "client_credentials"})
          .to_return(:status => 200,
                    :headers => {"Content-Type" => "application/json"},
                    :body => JSON.generate({ access_token: new_access_token, expires_in: expires_in }))
    end

    it "#current_token gets initial token" do
      expect(client.current_token).to be_a DwollaV2::Token
      expect(client.current_token.access_token).to eq new_access_token
    end

    it "#current_token re-uses fresh token" do
      expect(client.current_token).to be client.current_token
    end

    it "#get_token refreshes expired token" do
      client.current_token
      client.instance_variable_get(:@current_token).instance_variable_set(:@expires_at, Time.now - 1)

      expect(client.current_token).to be_a DwollaV2::Token
      expect(client.current_token.access_token).to eq new_access_token
    end
  end

  describe "delegated Token methods" do
    let!(:access_token) { "access_token" }
    let!(:client) { DwollaV2::Client.new(key: "key", secret: "secret") }
    let!(:res_body) { '{"foo":"bar"}' }

    before(:each) do
      stub_request(:post, client.token_url)
          .with(:basic_auth => [client.id, client.secret],
                :headers => {"Content-Type" => "application/x-www-form-urlencoded"},
                :body => {"grant_type" => "client_credentials"})
          .to_return(:status => 200,
                     :headers => {"Content-Type" => "application/json"},
                     :body => JSON.generate({ access_token: access_token, expires_in: 3600 }))
    end

    it "#get" do
      stub_request(:get, "https://api.dwolla.com/foo")
        .with(:headers => {
       	  "Accept" => "application/vnd.dwolla.v1.hal+json",
       	  "Authorization" => "Bearer #{access_token}"
        })
        .to_return(status: 200, body: res_body, headers: {})

      expect(client.get("foo").send :response_body).to eq res_body
    end

    it "#post" do
      stub_request(:post, "https://api.dwolla.com/foo")
        .with(:headers => {
          "Accept" => "application/vnd.dwolla.v1.hal+json",
          "Authorization" => "Bearer #{access_token}"
        })
        .to_return(status: 200, body: res_body, headers: {})

      expect(client.post("foo").send :response_body).to eq res_body
    end

    it "#delete" do
      stub_request(:delete, "https://api.dwolla.com/foo")
        .with(:headers => {
          "Accept" => "application/vnd.dwolla.v1.hal+json",
          "Authorization" => "Bearer #{access_token}"
        })
        .to_return(status: 200, body: res_body, headers: {})

      expect(client.delete("foo").send :response_body).to eq res_body
    end

    context "with expired token not caught by #is_expired? check" do
      let(:access_token) { "9JgZGdKChHhZHcTV7SGSm3bLS3vRpzruZxYA2DQdDSdhgezyKq" }
      let(:refresh_token) { "QfcxbZP4CTxw7gC5aQZgMQnH6zwQpgJr9NtQmXaSv5tk5CYEEp" }
      let(:client) {
        DwollaV2::Client.new(
          key: "key",
          secret: "secret",
          token: {
            access_token: access_token,
            refresh_token: refresh_token,
          },
        )
      }
      let(:res_body) { '{"foo":"bar"}' }
      let(:new_access_token) { "new-access-token" }
      let(:new_refresh_token) { "new-refresh-token" }
      let(:token_hash) {{
        :access_token => new_access_token,
        :token_type => "Bearer",
        :refresh_token => new_refresh_token,
        :expires_in => 3600,
        :refresh_expires_in => 5184000,
      }}

      it "#get" do
        # initial request fails with ExpiredAccessToken
        stub_request(:get, "https://api.dwolla.com/foo")
          .with(:headers => {
            "Accept" => "application/vnd.dwolla.v1.hal+json",
            "Authorization" => "Bearer #{access_token}"
          })
          .to_return(
            status: 401,
            body: JSON.generate({
              "code"=>"ExpiredAccessToken",
              "message"=>"Generate a new access token using your client credentials.",
            }),
            headers: {"Content-Type" => "application/json"},
          )
        # refresh token is refreshed
        stub_token_request(client,
          {:grant_type => "refresh_token", :refresh_token => refresh_token},
          {:status => 200, :body => token_hash}
        )
        # the original request is retried, and now succeeds
        stub_request(:get, "https://api.dwolla.com/foo")
          .with(:headers => {
             "Accept" => "application/vnd.dwolla.v1.hal+json",
             "Authorization" => "Bearer #{new_access_token}"
          })
          .to_return(status: 200, body: res_body, headers: {})

        expect(client.get("foo").send :response_body).to eq res_body
      end
    end
  end

  describe "openid methods" do
    let!(:client) { DwollaV2::Client.new(id: id, secret: secret) }
    let!(:redirect_uri) { "https://redirect.uri/dwolla/callback" }

    it "#auth returns DwollaV2::Auth" do
      auth = client.auth(redirect_uri: redirect_uri)
      
      expect(auth).to be_a DwollaV2::Auth
      expect(auth.url).to eq "#{client.auth_url}?#{URI.encode_www_form(
        response_type: "code",
        client_id: client.id,
        redirect_uri: redirect_uri
      )}"
    end

    it "#refresh_token returns ArgumentError" do
      expect {
        client.refresh_token()
      }.to raise_error {|e|
        expect(e).to be_a ArgumentError
        expect(e.message).to eq ":refresh_token is required"
      }
    end

    it "#refresh_token refreshes token" do
      refresh_token = "refresh-token"
      foo = "bar"
      token_hash = {:access_token => "access-token"}
      stub_token_request client,
                         {:grant_type => "refresh_token", :refresh_token => refresh_token, :foo => foo},
                         {:status => 200, :body => token_hash}
      
      token = client.refresh_token(refresh_token: refresh_token, foo: foo)
      
      expect(token).to be_a DwollaV2::Token
      expect(token.client).to be client
      expect(token.access_token).to eq token_hash[:access_token]
    end

    it "#token returns DwollaV2::Token" do
      access_token = "access-token"

      token = client.token(access_token: access_token)

      expect(token).to be_a DwollaV2::Token
      expect(token.access_token).to eq access_token
    end
  end

  private

  def stub_token_request client, params, response
    stub_request(:post, client.token_url)
      .with(:basic_auth => [client.id, client.secret],
            :headers => {"Content-Type" => "application/x-www-form-urlencoded"},
            :body => params)
      .to_return(:status => response[:status],
                 :headers => {"Content-Type" => "application/json"},
                 :body => JSON.generate(response[:body]))
  end
end
