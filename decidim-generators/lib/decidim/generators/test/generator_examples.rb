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

    expect(Pathname.new("#{test_app}/node_modules/@rails/webpacker")).to be_directory
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
      "DECIDIM_CORS_ENABLED" => "",
      "RAILS_LOG_LEVEL" => "nonsense"
    }
  end

  let(:env_false) do
    {
      "RAILS_ENV" => "production",
      "OMNIAUTH_FACEBOOK_APP_ID" => "false",
      "OMNIAUTH_FACEBOOK_APP_SECRET" => "false",
      "OMNIAUTH_TWITTER_API_KEY" => "no",
      "OMNIAUTH_TWITTER_API_SECRET" => "false",
      "OMNIAUTH_GOOGLE_CLIENT_ID" => "FalSe",
      "OMNIAUTH_GOOGLE_CLIENT_SECRET" => "false",
      "MAPS_API_KEY" => "0",
      "ETHERPAD_SERVER" => "No",
      "ETHERPAD_API_KEY" => "false",
      "DECIDIM_AVAILABLE_LOCALES" => "false",
      "DECIDIM_DEFAULT_LOCALE" => "false",
      "DECIDIM_ENABLE_HTML_HEADER_SNIPPETS" => "FalSe",
      "DECIDIM_CURRENCY_UNIT" => "false",
      "DECIDIM_IMAGE_UPLOADER_QUALITY" => "false",
      "DECIDIM_MAXIMUM_ATTACHMENT_SIZE" => "false",
      "DECIDIM_MAXIMUM_AVATAR_SIZE" => "false",
      "DECIDIM_MAX_REPORTS_BEFORE_HIDING" => "false",
      "DECIDIM_THROTTLING_MAX_REQUESTS" => "false",
      "DECIDIM_THROTTLING_PERIOD" => "false",
      "DECIDIM_UNCONFIRMED_ACCESS_FOR" => "false",
      "DECIDIM_SYSTEM_ACCESSLIST_IPS" => "false",
      "DECIDIM_CORS_ENABLED" => "falsE"
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
      "SECRET_KEY_BASE" => "a-secret-key-base",
      "SMTP_USERNAME" => "a-smtp-username",
      "SMTP_PASSWORD" => "a-smtp-password",
      "SMTP_ADDRESS" => "a-smtp-address",
      "SMTP_DOMAIN" => "a-smtp-domain",
      "SMTP_PORT" => "12345",
      "SMTP_STARTTLS_AUTO" => "a-smtp-starttls-auto",
      "SMTP_AUTHENTICATION" => "a-smtp-authentication",
      "BULLETIN_BOARD_SERVER" => "a-bulletin-board-server",
      "BULLETIN_BOARD_PUBLIC_KEY" => "a-bulletin-public-key",
      "BULLETIN_BOARD_API_KEY" => "an-authority-api-key",
      "AUTHORITY_NAME" => "an-authority-name",
      "AUTHORITY_PRIVATE_KEY" => "an-authority-private-key",
      "ELECTIONS_SCHEME_NAME" => "an-elections-scheme-name",
      "ELECTIONS_NUMBER_OF_TRUSTEES" => "345",
      "ELECTIONS_QUORUM" => "987",
      "DECIDIM_APPLICATION_NAME" => "\"A test\" {application}",
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
      "DECIDIM_CORS_ENABLED" => "true",
      "DECIDIM_CONSENT_COOKIE_NAME" => ":weird-consent-cookie-name:",
      "DECIDIM_CACHE_KEY_SEPARATOR" => ":",
      "DECIDIM_EXPIRE_SESSION_AFTER" => "45",
      "DECIDIM_ENABLE_REMEMBER_ME" => "",
      "DECIDIM_SESSION_TIMEOUT_INTERVAL" => "33",
      "DECIDIM_FOLLOW_HTTP_X_FORWARDED_HOST" => "true",
      "DECIDIM_MAXIMUM_CONVERSATION_MESSAGE_LENGTH" => "1234",
      "DECIDIM_PASSWORD_BLACKLIST" => "i-dont-like-this-password, i-dont,like,this,one,either, password123456",
      "DECIDIM_ALLOW_OPEN_REDIRECTS" => "true",
      "RAILS_LOG_LEVEL" => "fatal",
      "RAILS_ASSET_HOST" => "http://assets.example.org",
      "ETHERPAD_SERVER" => "http://a-etherpad-server.com",
      "ETHERPAD_API_KEY" => "an-etherpad-key",
      "ETHERPAD_API_VERSION" => "1.2.2",
      "MAPS_PROVIDER" => "here",
      "MAPS_API_KEY" => "a-maps-api-key",
      "VAPID_PUBLIC_KEY" => "a-vapid-public-key",
      "VAPID_PRIVATE_KEY" => "a-vapid-private-key"
    }
  end

  let(:env_maps_osm) do
    {
      "RAILS_ENV" => "production",
      "MAPS_PROVIDER" => "osm",
      "MAPS_API_KEY" => "another-maps-api-key",
      "MAPS_DYNAMIC_URL" => "https://tiles.example.org/{z}/{x}/{y}.png?key={apiKey}&{foo}",
      "MAPS_STATIC_URL" => "https://staticmap.example.org/",
      "MAPS_ATTRIBUTION" => '<a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap</a> contributors',
      "MAPS_GEOCODING_HOST" => "nominatim.example.org"
    }
  end

  let(:env_maps_mix) do
    {
      "RAILS_ENV" => "production",
      "MAPS_STATIC_PROVIDER" => "here",
      "MAPS_DYNAMIC_PROVIDER" => "osm",
      "MAPS_STATIC_API_KEY" => "a-maps-api-key",
      "MAPS_DYNAMIC_API_KEY" => "another-maps-api-key",
      "MAPS_DYNAMIC_URL" => "https://tiles.example.org/{z}/{x}/{y}.png?key={apiKey}&{foo}",
      "MAPS_ATTRIBUTION" => '<a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap</a> contributors',
      "MAPS_GEOCODING_HOST" => "nominatim.example.org",
      "MAPS_EXTRA_VARS" => URI.encode_www_form({ api_key: true, num: 123, foo: "bar=baz" })
    }
  end

  let(:secrets_off) do
    {
      %w(omniauth facebook enabled) => false,
      %w(omniauth twitter enabled) => false,
      %w(omniauth google_oauth2 enabled) => false,
      %w(decidim application_name) => "My Application Name",
      %w(decidim mailer_sender) => "change-me@example.org",
      %w(decidim available_locales) => %w(ca cs de en es eu fi fr it ja nl pl pt ro),
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
      %w(decidim cors_enabled) => false,
      %w(decidim consent_cookie_name) => "decidim-cc",
      %w(decidim cache_key_separator) => "/",
      %w(decidim expire_session_after) => 30,
      %w(decidim enable_remember_me) => "auto",
      %w(decidim session_timeout_interval) => 10,
      %w(decidim follow_http_x_forwarded_host) => false,
      %w(decidim maximum_conversation_message_length) => 1000,
      %w(decidim password_blacklist) => [],
      %w(decidim allow_open_redirects) => false,
      %w(etherpad server) => nil,
      %w(etherpad api_key) => nil,
      %w(etherpad api_version) => "1.2.1",
      %w(maps dynamic_provider) => nil,
      %w(maps static_provider) => nil,
      %w(maps static_api_key) => nil,
      %w(maps dynamic_api_key) => nil,
      %w(maps static_url) => nil,
      %w(maps dynamic_url) => nil,
      %w(maps attribution) => nil,
      %w(maps extra_vars) => nil,
      %w(maps geocoding_host) => nil,
      %w(vapid enabled) => false,
      %w(vapid public_key) => nil,
      %w(vapid private_key) => nil
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
      %w(secret_key_base) => "a-secret-key-base",
      %w(smtp_username) => "a-smtp-username",
      %w(smtp_password) => "a-smtp-password",
      %w(smtp_address) => "a-smtp-address",
      %w(smtp_domain) => "a-smtp-domain",
      %w(smtp_port) => 12_345,
      %w(smtp_starttls_auto) => true,
      %w(smtp_authentication) => "a-smtp-authentication",
      %w(elections bulletin_board_server) => "a-bulletin-board-server",
      %w(elections bulletin_board_public_key) => "a-bulletin-public-key",
      %w(elections authority_api_key) => "an-authority-api-key",
      %w(elections authority_name) => "an-authority-name",
      %w(elections authority_private_key) => "an-authority-private-key",
      %w(elections scheme_name) => "an-elections-scheme-name",
      %w(elections number_of_trustees) => 345,
      %w(elections quorum) => 987,
      %w(decidim application_name) => "\"A test\" {application}",
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
      %w(decidim cors_enabled) => true,
      %w(decidim consent_cookie_name) => ":weird-consent-cookie-name:",
      %w(decidim cache_key_separator) => ":",
      %w(decidim expire_session_after) => 45,
      %w(decidim enable_remember_me) => false,
      %w(decidim session_timeout_interval) => 33,
      %w(decidim follow_http_x_forwarded_host) => true,
      %w(decidim maximum_conversation_message_length) => 1234,
      %w(decidim password_blacklist) => ["i-dont-like-this-password", "i-dont,like,this,one,either", "password123456"],
      %w(decidim allow_open_redirects) => true,
      %w(etherpad server) => "http://a-etherpad-server.com",
      %w(etherpad api_key) => "an-etherpad-key",
      %w(etherpad api_version) => "1.2.2",
      %w(maps dynamic_provider) => "here",
      %w(maps static_provider) => "here",
      %w(maps static_api_key) => "a-maps-api-key",
      %w(maps dynamic_api_key) => "a-maps-api-key",
      %w(maps static_url) => nil,
      %w(maps dynamic_url) => nil,
      %w(maps attribution) => nil,
      %w(maps extra_vars) => nil,
      %w(maps geocoding_host) => nil,
      %w(vapid enabled) => true,
      %w(vapid public_key) => "a-vapid-public-key",
      %w(vapid private_key) => "a-vapid-private-key"
    }
  end

  let(:initializer_off) do
    {
      "application_name" => "My Application Name",
      "mailer_sender" => "change-me@example.org",
      "available_locales" => %w(ca cs de en es eu fi fr it ja nl pl pt ro),
      "default_locale" => "en",
      "force_ssl" => true,
      "enable_html_header_snippets" => false,
      "currency_unit" => "€",
      "image_uploader_quality" => 80,
      "maximum_attachment_size" => 10_485_760, # 10 megabytes
      "maximum_avatar_size" => 5_242_880, # 5 megabytes
      "max_reports_before_hiding" => 3,
      "track_newsletter_links" => true,
      "data_portability_expiry_time" => 604_800, # 7 days
      "throttling_max_requests" => 100,
      "throttling_period" => 60, # 1 minute
      "unconfirmed_access_for" => 0,
      "system_accesslist_ips" => [],
      "base_uploads_path" => nil,
      "default_csv_col_sep" => ";",
      "cors_enabled" => false,
      "consent_cookie_name" => "decidim-cc",
      "cache_key_separator" => "/",
      "expire_session_after" => 1800, # 30 minutes
      "enable_remember_me" => true,
      "session_timeout_interval" => 10,
      "follow_http_x_forwarded_host" => false,
      "maximum_conversation_message_length" => 1000,
      "password_blacklist" => [],
      "allow_open_redirects" => false,
      "etherpad" => nil,
      "maps" => nil
    }
  end

  let(:initializer_on) do
    {
      "application_name" => "\"A test\" {application}",
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
      "consent_cookie_name" => ":weird-consent-cookie-name:",
      "cache_key_separator" => ":",
      "expire_session_after" => 2700, # 45 minutes
      "enable_remember_me" => false,
      "session_timeout_interval" => 33,
      "follow_http_x_forwarded_host" => true,
      "maximum_conversation_message_length" => 1234,
      "password_blacklist" => ["i-dont-like-this-password", "i-dont,like,this,one,either", "password123456"],
      "allow_open_redirects" => true,
      "etherpad" => {
        "server" => "http://a-etherpad-server.com",
        "api_key" => "an-etherpad-key",
        "api_version" => "1.2.2"
      },
      "maps" => {
        "provider" => "here",
        "api_key" => "a-maps-api-key",
        "static" => {
          "url" => "https://image.maps.ls.hereapi.com/mia/1.6/mapview"
        },
        "dynamic" => {
          "provider" => "here",
          "api_key" => "a-maps-api-key",
          "tile_layer" => {}
        }
      }
    }
  end

  let(:initializer_maps_osm) do
    {
      "maps" => {
        "provider" => "osm",
        "api_key" => "another-maps-api-key",
        "static" => {
          "url" => "https://staticmap.example.org/"
        },
        "dynamic" => {
          "provider" => "osm",
          "api_key" => "another-maps-api-key",
          "tile_layer" => {
            "url" => "https://tiles.example.org/{z}/{x}/{y}.png?key={apiKey}&{foo}",
            "attribution" => '<a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap</a> contributors'
          }
        },
        "geocoding" => {
          "host" => "nominatim.example.org",
          "use_https" => true
        }
      }
    }
  end

  let(:initializer_maps_mix) do
    {
      "maps" => {
        "provider" => "here",
        "api_key" => "a-maps-api-key",
        "static" => {
          "url" => "https://image.maps.ls.hereapi.com/mia/1.6/mapview"
        },
        "dynamic" => {
          "provider" => "osm",
          "api_key" => "another-maps-api-key",
          "tile_layer" => {
            "url" => "https://tiles.example.org/{z}/{x}/{y}.png?key={apiKey}&{foo}",
            "attribution" => '<a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap</a> contributors',
            "api_key" => true,
            "num" => 123,
            "foo" => "bar=baz"
          }
        },
        "geocoding" => {
          "host" => "nominatim.example.org",
          "use_https" => true
        }
      }
    }
  end

  # The logs settings have changed between Rails 6.0 abd 6.1 and this may be here
  # https://github.com/rails/rails/commit/73079940111e8b85bf87953e5ef9fafeece5b5da
  let(:rails_off) do
    {
      "Rails.logger.level" => 1,
      "Rails.application.config.log_level" => "info",
      "Rails.application.config.action_controller.asset_host" => nil
    }
  end

  let(:rails_on) do
    {
      "Rails.logger.level" => 4,
      "Rails.application.config.log_level" => "fatal",
      "Rails.application.config.action_controller.asset_host" => "http://assets.example.org"
    }
  end

  it "env vars generate secrets application" do
    expect(result[1]).to be_success, result[0]
    # Test onto the secret generated when ENV vars are empty strings or undefined
    json_off = json_secrets_for(test_app, env_off)
    secrets_off.each do |keys, value|
      current = json_off.dig(*keys)
      expect(current).to eq(value), "Secret #{keys} = (#{current}) expected to match Env:OFF (#{value})"
    end

    # Test onto the secret generated when ENV vars are set
    json_on = json_secrets_for(test_app, env_on)
    secrets_on.each do |keys, value|
      current = json_on.dig(*keys)
      expect(current).to eq(value), "Secret #{keys} = (#{current}) expected to match Env:ON (#{value})"
    end

    # Test onto the initializer when ENV vars are empty strings or undefined
    json_off = initializer_config_for(test_app, env_off)
    initializer_off.each do |key, value|
      current = json_off[key]
      expect(current).to eq(value), "Initializer (#{key}) = (#{current}) expected to match Env:OFF (#{value})"
    end

    # Test onto the initializer when ENV vars are set to the string "false"
    json_false = initializer_config_for(test_app, env_false)
    initializer_off.each do |key, value|
      current = json_false[key]
      expect(current).to eq(value), "Initializer (#{key}) = (#{current}) expected to match Env:FALSE (#{value})"
    end

    # Test onto the initializer when ENV vars are set
    json_on = initializer_config_for(test_app, env_on)
    initializer_on.each do |key, value|
      current = json_on[key]
      expect(current).to eq(value), "Initializer (#{key}) = (#{current}) expected to match Env:ON (#{value})"
    end

    # Test onto the initializer when ENV vars are set to OpenstreetMap configuration
    json_on = initializer_config_for(test_app, env_maps_osm)
    initializer_maps_osm.each do |key, value|
      current = json_on[key]
      expect(current).to eq(value), "Initializer (#{key}) = (#{current}) expected to match Env:Maps OSM (#{value})"
    end

    # Test onto the initializer when ENV vars are set to OpenstreetMap-HERE mix configuration
    json_on = initializer_config_for(test_app, env_maps_mix)
    initializer_maps_mix.each do |key, value|
      current = json_on[key]
      expect(current).to eq(value), "Initializer (#{key}) = (#{current}) expected to match Env:Maps MIX (#{value})"
    end

    # Test onto some extra Rails confing when ENV vars are empty or undefined
    rails_off.each do |key, value|
      current = rails_value(key, test_app, env_off)
      expect(current).to eq(value), "Rails config (#{key}) = (#{current}) expected to match Env:OFF (#{value})"
    end

    # Test onto some extra Rails confing when ENV vars are set
    rails_on.each do |key, value|
      current = rails_value(key, test_app, env_on)
      expect(current).to eq(value), "Rails config (#{key}) = (#{current}) expected to match Env:ON (#{value})"
    end
  end
end

def json_secrets_for(path, env)
  JSON.parse Decidim::GemManager.new(path).capture("bin/rails runner 'puts Rails.application.secrets.to_json'", env: env, with_stderr: false)[0]
end

def initializer_config_for(path, env)
  JSON.parse Decidim::GemManager.new(path).capture("bin/rails runner 'puts Decidim.config.to_json'", env: env, with_stderr: false)[0]
end

def rails_value(value, path, env)
  JSON.parse Decidim::GemManager.new(path).capture("bin/rails runner 'puts #{value}.to_json'", env: env, with_stderr: false)[0]
end
