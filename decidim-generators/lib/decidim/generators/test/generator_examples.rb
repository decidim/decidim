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
  # ensure that empty env behave like non-defined envs
  let(:env_off) do
    {
      "RAILS_ENV" => "production",
      "OMNIAUTH_FACEBOOK_APP_ID" => "",
      "OMNIAUTH_FACEBOOK_APP_SECRET" => "",
      "OMNIAUTH_TWITTER_API_KEY" => "",
      "OMNIAUTH_TWITTER_API_SECRET" => "",
      "OMNIAUTH_GOOGLE_CLIENT_ID" => "",
      "OMNIAUTH_GOOGLE_CLIENT_SECRET" => "",
      "MAPS_API_KEY" => "",
      "ETHERPAD_SERVER" => "",
      "ETHERPAD_API_KEY" => "",
      "DECIDIM_APPLICATION_NAME" => "",
      "DECIDIM_MAILER_SENDER" => "",
      "DECIDIM_AVAILABLE_LOCALES" => "",
      "DECIDIM_DEFAULT_LOCALE" => "",
      "DECIDIM_ENABLE_HTML_HEADER_SNIPPETS" => "",
      "DECIDIM_CURRENCY_UNIT" => "",
      "DECIDIM_IMAGE_UPLOADER_QUALITY" => "",
      "DECIDIM_MAXIMUM_ATTACHMENT_SIZE" => "",
      "DECIDIM_MAXIMUM_AVATAR_SIZE" => "",
      "DECIDIM_MAX_REPORTS_BEFORE_HIDING" => "",
      "DECIDIM_THROTTLING_MAX_REQUESTS" => "",
      "DECIDIM_THROTTLING_PERIOD" => "",
      "DECIDIM_UNCONFIRMED_ACCESS_FOR" => "",
      "DECIDIM_SYSTEM_ACCESSLIST_IPS" => "",
      "DECIDIM_BASE_UPLOADS_PATH" => "",
      "DECIDIM_DEFAULT_CSV_COL_SEP" => "",
      "DECIDIM_CORS_ENABLED" => ""
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
      "SERVICE_SMS_GATEWAY" => "MySMSGatewayService",
      "SERVICE_TIMESTAMP" => "MyTimestampService",
      "SERVICE_PDF_SIGNATURE" => "MyPDFSignatureService",
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
      "DECIDIM_FORCE_SSL" => "",
      "DECIDIM_ENABLE_HTML_HEADER_SNIPPETS" => "true",
      "DECIDIM_CURRENCY_UNIT" => "$",
      "DECIDIM_IMAGE_UPLOADER_QUALITY" => "91",
      "DECIDIM_MAXIMUM_ATTACHMENT_SIZE" => "25",
      "DECIDIM_MAXIMUM_AVATAR_SIZE" => "11",
      "DECIDIM_MAX_REPORTS_BEFORE_HIDING" => "4",
      "DECIDIM_TRACK_NEWSLETTER_LINKS" => "",
      "DECIDIM_DATA_PORTABILITY_EXPIRY_TIME" => "2",
      "DECIDIM_THROTTLING_MAX_REQUESTS" => "99",
      "DECIDIM_THROTTLING_PERIOD" => "2",
      "DECIDIM_UNCONFIRMED_ACCESS_FOR" => "3",
      "DECIDIM_SYSTEM_ACCESSLIST_IPS" => "127.0.0.1,172.26.0.1/24",
      "DECIDIM_BASE_UPLOADS_PATH" => "some-path/",
      "DECIDIM_DEFAULT_CSV_COL_SEP" => ",",
      "DECIDIM_CORS_ENABLED" => "true"
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
      %w(decidim force_ssl) => "auto",
      %w(decidim enable_html_header_snippets) => false,
      %w(decidim currency_unit) => "€",
      %w(decidim image_uploader_quality) => 80,
      %w(decidim maximum_attachment_size) => 10,
      %w(decidim maximum_avatar_size) => 5,
      %w(decidim max_reports_before_hiding) => 3,
      %w(decidim track_newsletter_links) => "auto",
      %w(decidim data_portability_expiry_time) => 7,
      %w(decidim throttling_max_requests) => 100,
      %w(decidim throttling_period) => 1,
      %w(decidim unconfirmed_access_for) => 0,
      %w(decidim system_accesslist_ips) => [],
      %w(decidim base_uploads_path) => nil,
      %w(decidim default_csv_col_sep) => ";",
      %w(decidim cors_enabled) => false
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
      %w(services sms_gateway) => "MySMSGatewayService",
      %w(services timestamp) => "MyTimestampService",
      %w(services pdf_signature) => "MyPDFSignatureService",
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
      %w(decidim force_ssl) => false,
      %w(decidim enable_html_header_snippets) => true,
      %w(decidim currency_unit) => "$",
      %w(decidim image_uploader_quality) => 91,
      %w(decidim maximum_attachment_size) => 25,
      %w(decidim maximum_avatar_size) => 11,
      %w(decidim max_reports_before_hiding) => 4,
      %w(decidim track_newsletter_links) => false,
      %w(decidim data_portability_expiry_time) => 2,
      %w(decidim throttling_max_requests) => 99,
      %w(decidim throttling_period) => 2,
      %w(decidim unconfirmed_access_for) => 3,
      %w(decidim system_accesslist_ips) => ["127.0.0.1", "172.26.0.1/24"],
      %w(decidim base_uploads_path) => "some-path/",
      %w(decidim default_csv_col_sep) => ",",
      %w(decidim cors_enabled) => true
    }
  end

  let(:initializer_off) do
    {
      "application_name" => "My Application Name",
      "mailer_sender" => "change-me@example.org",
      "available_locales" => %w(en ca es),
      "default_locale" => "en",
      "force_ssl" => true,
      "enable_html_header_snippets" => false,
      "currency_unit" => "€",
      "image_uploader_quality" => 80,
      "maximum_attachment_size" => 10_485_760, # 10 megabytes
      "maximum_avatar_size" => 5_242_880, # 5 megabytes
      "max_reports_before_hiding" => 3,
      "track_newsletter_links" => true,
      "data_portability_expiry_time" => 604_800, # 7 days,
      "throttling_max_requests" => 100,
      "throttling_period" => 60, # 1 minute
      "unconfirmed_access_for" => 0,
      "system_accesslist_ips" => [],
      "base_uploads_path" => nil,
      "default_csv_col_sep" => ";",
      "cors_enabled" => false
    }
  end

  let(:initializer_on) do
    {
      "application_name" => "A test application",
      "mailer_sender" => "noreply@example.org",
      "available_locales" => %w(de fr zh-CN),
      "default_locale" => "zh-CN",
      "force_ssl" => false,
      "enable_html_header_snippets" => true,
      "currency_unit" => "$",
      "image_uploader_quality" => 91,
      "maximum_attachment_size" => 26_214_400, # 25 megabytes
      "maximum_avatar_size" => 11_534_336, # 11 megabytes
      "max_reports_before_hiding" => 4,
      "track_newsletter_links" => false,
      "data_portability_expiry_time" => 172_800, # 2 days
      "throttling_max_requests" => 99,
      "throttling_period" => 120, # 2 minutes
      "unconfirmed_access_for" => 259_200, # 3 days
      "system_accesslist_ips" => ["127.0.0.1", "172.26.0.1/24"],
      "base_uploads_path" => "some-path/",
      "default_csv_col_sep" => ",",
      "cors_enabled" => true,
      "sms_gateway_service" => "MySMSGatewayService",
      "timestamp_service" => "MyTimestampService",
      "pdf_signature_service" => "MyPDFSignatureService"
    }
  end

  it "env vars generate secrets application" do
    expect(result[1]).to be_success, result[0]

    json_off = json_secrets_for(test_app, env_off)
    secrets_off.each do |keys, value|
      current = json_off.dig(*keys)
      expect(current).to eq(value), "Secret #{keys} = (#{current}) expected to match Env OFF (#{value})"
    end

    json_on = json_secrets_for(test_app, env_on)
    secrets_on.each do |keys, value|
      current = json_on.dig(*keys)
      expect(current).to eq(value), "Secret #{keys} = (#{current}) expected to match Env ON (#{value})"
    end

    json_off = initializer_config_for(test_app, env_off)
    initializer_off.each do |key, value|
      current = json_off[key]
      expect(current).to eq(value), "Initializer (#{key}) = (#{current}) expected to match Env OFF (#{value})"
    end

    json_on = initializer_config_for(test_app, env_on)
    initializer_on.each do |key, value|
      current = json_on[key]
      expect(current).to eq(value), "Initializer (#{key}) = (#{current}) expected to match Env ON (#{value})"
    end
  end
end

def json_secrets_for(path, env)
  JSON.parse Decidim::GemManager.new(path).capture("bin/rails runner 'puts Rails.application.secrets.to_json'", env: env, with_stderr: false)[0]
end

def initializer_config_for(path, env)
  JSON.parse Decidim::GemManager.new(path).capture("bin/rails runner 'puts Decidim.config.to_json'", env: env, with_stderr: false)[0]
end
