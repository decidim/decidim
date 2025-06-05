# frozen_string_literal: true

require "spec_helper"

describe "API OAuth" do
  let!(:organization) { create(:organization) }
  let(:organization_host) { "http://#{organization.host}:#{Capybara.server_port}" }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:oauth_application) do
    create(
      :oauth_application,
      organization:,
      scopes: "user api:read",
      confidential:,
      redirect_uri:
    )
  end
  # Doorkeeper defines a special action for passing the authorization code back
  # to native apps. This should be primarily used only with public clients but
  # for the sake of testing, we use the same redirect URI for testing both types
  # of OAuth applications.
  let(:redirect_uri) { "#{organization_host}/oauth/authorize/native" }
  let(:confidential) { true }

  around do |example|
    config = WebMock::Config.instance
    orig_allow = config.allow
    config.allow << %r{http://[0-9]+\.lvh\.me:#{Capybara.server_port}/}

    example.run

    config.allow = orig_allow
  end

  before do
    allow(Doorkeeper.config).to receive(:force_ssl_in_redirect_uri).and_return(false)
    oauth_application

    switch_to_host(organization.host)
  end

  shared_examples "performs API queries with the assigned OAuth token" do
    let(:authorization) { api_authorization(token_scope) }
    let(:query) { "{ session { user { id name nickname } } }" }
    let(:graphql_data) { graphql_request(authorization, query) }

    context "with user and api:read scopes" do
      let(:token_scope) { "user api:read" }

      it "shows the user details when authenticated with the API" do
        details = graphql_data.dig("session", "user")
        expect(details).to match(
          "id" => user.id.to_s,
          "name" => user.name,
          "nickname" => "@#{user.nickname}"
        )
      end
    end

    context "with user scope" do
      let(:token_scope) { "user" }

      it "does not allow reading data through the API" do
        expect(graphql_data).to be_nil
      end
    end

    context "with api:read scope" do
      let(:token_scope) { "api:read" }

      it "does not allow reading user data through the API" do
        expect(graphql_data).to match("session" => nil)
      end
    end
  end

  context "with a confidential OAuth client" do
    it_behaves_like "performs API queries with the assigned OAuth token"
  end

  context "with a public OAuth client" do
    let(:confidential) { false }

    it_behaves_like "performs API queries with the assigned OAuth token"
  end

  # Runs through the whole OAuth authorization code flow to fetch a valid OAuth
  # token with the given scopes.
  def api_authorization(scope)
    # https://datatracker.ietf.org/doc/html/rfc6749#appendix-A.5
    chars = Array(0x20..0x7E).map(&:chr)
    state = Base64.urlsafe_encode64(random_string(chars, 36), padding: false)

    # https://datatracker.ietf.org/doc/html/rfc7636#section-4.1
    chars = Array(0x30..0x39).map(&:chr) + Array(0x41..0x5A).map(&:chr) +
            Array(0x61..0x7A).map(&:chr) + "-._~".chars
    verifier = random_string(chars, 96)
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)

    # https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.1
    # https://datatracker.ietf.org/doc/html/rfc7636
    params = {
      response_type: "code",
      client_id: oauth_application.uid,
      redirect_uri:,
      scope:,
      state:,
      code_challenge: challenge,
      code_challenge_method: "S256"
    }

    visit "/oauth/authorize?#{URI.encode_www_form(params)}"
    expect(page).to have_content("Log in")

    within "#session_new_user" do
      fill_in :session_user_email, with: user.email
      fill_in :session_user_password, with: "decidim123456789"
      find("*[type=submit]").click
    end

    expect(page).to have_content("Logged in successfully.")
    click_on "Authorize application"

    expect(page).to have_content("Authorization code:")

    page_params = Rack::Utils.parse_query(URI.parse(page.current_url).query)
    raise "Invalid OAuth state returned." if page_params["state"] != state

    code = page_params["code"]
    token = fetch_token(code, verifier)
    %w(token_type access_token).map { |key| token[key] }.join(" ")
  end

  def fetch_token(code, verifier)
    # https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.3
    # https://datatracker.ietf.org/doc/html/rfc7636
    uri = URI.parse("#{organization_host}/oauth/token")
    request = Net::HTTP::Post.new(uri)
    data = {
      grant_type: "authorization_code",
      code:,
      redirect_uri:,
      client_id: oauth_application.uid,
      code_verifier: verifier
    }
    data[:client_secret] = oauth_application.secret if confidential
    request.set_form_data(data)

    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(request)
    raise "Invalid response from token request: #{response.code}" unless response.is_a?(Net::HTTPOK)
    raise "Unexpected content type from token request: #{response.content_type}" unless response.content_type == "application/json"

    JSON.parse(response.body)
  end

  def graphql_request(authorization, query)
    uri = URI.parse("#{organization_host}/api")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = authorization
    request["Content-Type"] = "application/json; charset=utf-8"
    request["X-Jwt-Aud"] = oauth_application.uid
    request.body = { query: }.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(request)
    raise "Invalid response from the API: #{response.code}" unless response.is_a?(Net::HTTPOK)
    raise "Unexpected content type from the API: #{response.content_type}" unless response.content_type == "application/json"

    details = JSON.parse(response.body)
    details["data"]
  end

  def random_string(chars, length)
    Array.new(length) { chars[SecureRandom.random_number(chars.length)] }.join
  end
end
