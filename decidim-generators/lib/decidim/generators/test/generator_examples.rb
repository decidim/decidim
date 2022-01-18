# frozen_string_literal: true

shared_examples_for "a new production application" do
  it "includes optional plugins commented out in Gemfile" do
    expect(result[1]).to be_success, result[0]

    expect(File.read("#{test_app}/Gemfile"))
      .to match(/^# gem "decidim-initiatives"/)
      .and match(/^# gem "decidim-consultations"/)
      .and match(/^# gem "decidim-elections"/)
      .and match(/^# gem "decidim-conferences"/)
      .and match(/^# gem "decidim-templates"/)
  end
end

shared_examples_for "a new development application" do
  it "includes optional plugins uncommented in Gemfile" do
    expect(result[1]).to be_success, result[0]

    expect(File.read("#{test_app}/Gemfile"))
      .to match(/^gem "decidim-initiatives"/)
      .and match(/^gem "decidim-consultations"/)
      .and match(/^gem "decidim-elections"/)
      .and match(/^gem "decidim-conferences"/)
      .and match(/^gem "decidim-templates"/)

    # Checks that every table from a migration is included in the generated schema
    schema = File.read("#{test_app}/db/schema.rb")
    tables = []
    dropped = []
    Decidim::GemManager.plugins.each do |plugin|
      Dir.glob("#{plugin}db/migrate/*.rb").each do |migration|
        lines = File.readlines(migration)
        tables.concat(lines.filter { |line| line.match? "create_table" }.map { |line| line.match(/(:)([a-z_0-9]+)/)[2] })
        dropped.concat(lines.filter { |line| line.match? "drop_table" }.map { |line| line.match(/(:)([a-z_0-9]+)/)[2] })
        tables.concat(lines.filter { |line| line.match? "rename_table" }.map { |line| line.match(/(, :)([a-z_0-9]+)/)[2] })
        dropped.concat(lines.filter { |line| line.match? "rename_table" }.map { |line| line.match(/(:)([a-z_0-9]+)/)[2] })
      end
    end
    tables.each do |table|
      next if dropped.include? table

      expect(schema).to match(/create_table "#{table}"|create_table :#{table}/)
    end
  end
end

shared_examples_for "an application with configurable env vars" do
  let(:env_off) do
    {
      "RAILS_ENV" => "production"
    }
  end

  let(:env_on) do
    {
      "RAILS_ENV" => "production",
      "OMNIAUTH_FACEBOOK_APP_ID" => "a-facebook-id",
      "OMNIAUTH_FACEBOOK_APP_SECRET" => "a-facebook-secret",
      "OMNIAUTH_TWITTER_API_KEY" => "a-twitter-api-key",
      "OMNIAUTH_TWITTER_API_SECRET" => "a-twitter-api-secret",
      "OMNIAUTH_GOOGLE_CLIENT_ID" => "a-google-client-id",
      "OMNIAUTH_GOOGLE_CLIENT_SECRET" => "a-google-client-secret",
      "MAPS_API_KEY" => "a-maps-api-key",
      "ETHERPAD_SERVER" => "a-etherpad-server",
      "ETHERPAD_API_KEY" => "a-etherpad-key",
      "SECRET_KEY_BASE" => "a-secret-key-base",
      "SMTP_USERNAME" => "a-smtp-username",
      "SMTP_PASSWORD" => "a-smtp-password",
      "SMTP_ADDRESS" => "a-smtp-address",
      "SMTP_DOMAIN" => "a-smtp-domain",
      "SMTP_PORT" => "a-smtp-port",
      "SMTP_STARTTLS_AUTO" => "a-smtp-starttls-auto",
      "SMTP_AUTHENTICATION" => "a-smtp-authentication",
      "BULLETIN_BOARD_SERVER" => "a-bulletin-board-server",
      "BULLETIN_BOARD_PUBLIC_KEY" => "a-bulletin-public-key",
      "BULLETIN_BOARD_API_KEY" => "an-authority-api-key",
      "AUTHORITY_NAME" => "an-authority-name",
      "AUTHORITY_PRIVATE_KEY" => "an-authority-private-key",
      "ELECTIONS_SCHEME_NAME" => "an-elections-scheme-name",
      "ELECTIONS_NUMBER_OF_TRUSTEES" => "an-elections-number-of-trustees",
      "ELECTIONS_QUORUM" => "an-elections-quorum",
      "DECIDIM_APPLICATION_NAME" => "A test application",
      "DECIDIM_MAILER_SENDER" => "noreply@example.org",
      "DECIDIM_AVAILABLE_LOCALES" => "de, fr, zh-CN",
      "DECIDIM_DEFAULT_LOCALE" => "zh-CN",
      "DECIDIM_DISABLE_SSL" => "true"
    }
  end

  let(:secrets_off) do
    {
      %w(omniauth facebook enabled) => false,
      %w(omniauth twitter enabled) => false,
      %w(omniauth google_oauth2 enabled) => false,
      %w(decidim application_name) => "My Application Name",
      %w(decidim mailer_sender) => "change-me@example.org",
      %w(decidim available_locales) => %w(en ca es),
      %w(decidim default_locale) => "en",
      %w(decidim force_ssl) => true
    }
  end

  let(:secrets_on) do
    {
      %w(omniauth facebook enabled) => true,
      %w(omniauth facebook app_id) => "a-facebook-id",
      %w(omniauth facebook app_secret) => "a-facebook-secret",
      %w(omniauth twitter enabled) => true,
      %w(omniauth twitter api_key) => "a-twitter-api-key",
      %w(omniauth twitter api_secret) => "a-twitter-api-secret",
      %w(omniauth google_oauth2 enabled) => true,
      %w(omniauth google_oauth2 client_id) => "a-google-client-id",
      %w(omniauth google_oauth2 client_secret) => "a-google-client-secret",
      %w(maps api_key) => "a-maps-api-key",
      %w(etherpad server) => "a-etherpad-server",
      %w(etherpad api_key) => "a-etherpad-key",
      %w(secret_key_base) => "a-secret-key-base",
      %w(smtp_username) => "a-smtp-username",
      %w(smtp_password) => "a-smtp-password",
      %w(smtp_address) => "a-smtp-address",
      %w(smtp_domain) => "a-smtp-domain",
      %w(smtp_port) => "a-smtp-port",
      %w(smtp_starttls_auto) => "a-smtp-starttls-auto",
      %w(smtp_authentication) => "a-smtp-authentication",
      %w(elections bulletin_board_server) => "a-bulletin-board-server",
      %w(elections bulletin_board_public_key) => "a-bulletin-public-key",
      %w(elections authority_api_key) => "an-authority-api-key",
      %w(elections authority_name) => "an-authority-name",
      %w(elections authority_private_key) => "an-authority-private-key",
      %w(elections scheme_name) => "an-elections-scheme-name",
      %w(elections number_of_trustees) => "an-elections-number-of-trustees",
      %w(elections quorum) => "an-elections-quorum",
      %w(decidim application_name) => "A test application",
      %w(decidim mailer_sender) => "noreply@example.org",
      %w(decidim available_locales) => %w(de fr zh-CN),
      %w(decidim default_locale) => "zh-CN",
      %w(decidim force_ssl) => false

    }
  end

  let(:initializer_off) do
    {
      "application_name" => "My Application Name",
      "mailer_sender" => "change-me@example.org",
      "available_locales" => %w(en ca es),
      "default_locale" => "en",
      "force_ssl" => true
    }
  end

  let(:initializer_on) do
    {
      "application_name" => "A test application",
      "mailer_sender" => "noreply@example.org",
      "available_locales" => %w(de fr zh-CN),
      "default_locale" => "zh-CN",
      "force_ssl" => false
    }
  end

  it "env vars generate secrets application" do
    expect(result[1]).to be_success, result[0]

    json_off = json_secrets_for(test_app, env_off)
    secrets_off.each do |keys, value|
      current = json_off.dig(*keys)
      expect(current).to eq(value), "Secret #{keys} = [#{current}] expected to match Env OFF [#{value}]"
    end

    json_on = json_secrets_for(test_app, env_on)
    secrets_on.each do |keys, value|
      current = json_on.dig(*keys)
      expect(current).to eq(value), "Secret #{keys} = [#{current}] expected to match Env ON [#{value}]"
    end

    json_off = initializer_config_for(test_app, env_off)
    initializer_off.each do |key, value|
      current = json_off[key]
      expect(current).to eq(value), "Initializer [#{key}] = [#{current}] expected to match Env OFF [#{value}]"
    end

    json_on = initializer_config_for(test_app, env_on)
    initializer_on.each do |key, value|
      current = json_on[key]
      expect(current).to eq(value), "Initializer [#{key}] = [#{current}] expected to match Env ON [#{value}]"
    end
  end
end

def json_secrets_for(path, env)
  JSON.parse Decidim::GemManager.new(path).capture("bin/rails runner 'puts Rails.application.secrets.to_json'", env: env, with_stderr: false)[0]
end

def initializer_config_for(path, env)
  JSON.parse Decidim::GemManager.new(path).capture("bin/rails runner 'puts Decidim.config.to_json'", env: env, with_stderr: false)[0]
end
