# frozen_string_literal: true

require "spec_helper"

module OAuthSystemSpecHelpers
  def visit_oauth_authorization_page(scope = nil)
    scope ||= self.scope
    authorization = oauth_authorization_details(scope)
    visit "/oauth/authorize?#{URI.encode_www_form(authorization[:params])}"
    expect(page).to have_content("Log in")

    within "#session_new_user" do
      fill_in :session_user_email, with: user.email
      fill_in :session_user_password, with: "decidim123456789"
      find("*[type=submit]").click
    end

    expect(page).to have_content("Logged in successfully.")

    authorization
  end

  def oauth_api_authorization(scope)
    token = oauth_api_token(scope)
    %w(token_type access_token).map { |key| token[key] }.join(" ")
  end

  # Runs through the whole OAuth authorization code flow to fetch a valid OAuth
  # token with the given scopes.
  def oauth_api_token(scope)
    authorization = visit_oauth_authorization_page(scope)

    click_on "Authorize application"

    expect(page).to have_content("Authorization code:")

    page_params = Rack::Utils.parse_query(URI.parse(page.current_url).query)
    raise "Invalid OAuth state returned." if page_params["state"] != authorization[:state]

    code = page_params["code"]
    oauth_fetch_token(code, authorization[:verifier])
  end

  def oauth_authorization_details(scope)
    # https://datatracker.ietf.org/doc/html/rfc6749#appendix-A.5
    chars = Array(0x20..0x7E).map(&:chr)
    state = Base64.urlsafe_encode64(oauth_random_string(chars, 36), padding: false)

    # https://datatracker.ietf.org/doc/html/rfc7636#section-4.1
    chars = Array(0x30..0x39).map(&:chr) + Array(0x41..0x5A).map(&:chr) +
            Array(0x61..0x7A).map(&:chr) + "-._~".chars
    verifier = oauth_random_string(chars, 96)
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

    { params:, state:, verifier: }
  end

  def oauth_fetch_token(code, verifier)
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

  def oauth_random_string(chars, length)
    Array.new(length) { chars[SecureRandom.random_number(chars.length)] }.join
  end
end

shared_context "with oauth application" do
  include OAuthSystemSpecHelpers

  let!(:organization) { create(:organization) }
  let(:organization_host) { "http://#{organization.host}:#{Capybara.server_port}" }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:available_scopes) { Doorkeeper.config.scopes.to_s }
  let(:oauth_application) do
    create(
      :oauth_application,
      organization:,
      scopes: available_scopes,
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
end
