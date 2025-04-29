# frozen_string_literal: true

require "uri"

shared_context "when generating a new application" do
  let(:env) do |example|
    #
    # When tracking coverage, make sure the ruby environment points to the
    # local version, so we get the benefits of running `decidim` directly
    # without `bundler` (more realistic test), but also get code coverage
    # properly measured (we track coverage on the local version and not on the
    # installed version).
    #
    if ENV["SIMPLECOV"]
      {
        "RUBYOPT" => "-rsimplecov #{ENV.fetch("RUBYOPT", nil)}",
        "RUBYLIB" => "#{repo_root}/decidim-generators/lib:#{ENV.fetch("RUBYLIB", nil)}",
        "PATH" => "#{repo_root}/decidim-generators/exe:#{ENV.fetch("PATH", nil)}",
        "COMMAND_NAME" => example.full_description.tr(" ", "_")
      }
    else
      {}
    end
  end

  let(:result) do
    Bundler.with_original_env { Decidim::GemManager.capture(command, env:) }
  end

  # rubocop:disable RSpec/BeforeAfterAll
  before(:all) do
    Bundler.with_original_env { Decidim::GemManager.install_all(out: File::NULL) }
  end

  after(:all) do
    Bundler.with_original_env { Decidim::GemManager.uninstall_all(out: File::NULL) }
  end
  # rubocop:enable RSpec/BeforeAfterAll
end

shared_examples_for "a new production application" do
  it "includes optional plugins commented out in Gemfile" do
    expect(result[1]).to be_success, result[0]

    expect(File.read("#{test_app}/Gemfile"))
      .to match(/^# gem "decidim-initiatives"/)
      .and match(/^# gem "decidim-conferences"/)
      .and match(/^# gem "decidim-templates"/)
      .and match(/^# gem "decidim-collaborative_texts"/)
      .and match(/^# gem "decidim-elections"/)
  end
end

shared_examples_for "a new development application" do
  it "includes optional plugins uncommented in Gemfile" do
    expect(result[1]).to be_success, result[0]

    expect(File.read("#{test_app}/Gemfile"))
      .to match(/^gem "decidim-initiatives"/)
      .and match(/^gem "decidim-conferences"/)
      .and match(/^gem "decidim-templates"/)
      .and match(/^gem "decidim-collaborative_texts"/)
      .and match(/^gem "decidim-elections"/)

    # Checks that every table from a migration is included in the generated schema
    schema = File.read("#{test_app}/db/schema.rb")
    tables = []
    dropped = []
    Decidim::GemManager.plugins.each do |plugin|
      Dir.glob("#{plugin}db/migrate/*.rb").each do |migration|
        lines = File.readlines(migration)
        tables.concat(lines.grep(/create_table/).map { |line| line.match(/(:)([a-z_0-9]+)/)[2] })
        dropped.concat(lines.grep(/drop_table/).map { |line| line.match(/(:)([a-z_0-9]+)/)[2] })
        tables.concat(lines.grep(/rename_table/).map { |line| line.match(/(, :)([a-z_0-9]+)/)[2] })
        dropped.concat(lines.grep(/rename_table/).map { |line| line.match(/(:)([a-z_0-9]+)/)[2] })
      end
    end
    tables.each do |table|
      next if dropped.include? table

      expect(schema).to match(/create_table "#{table}"|create_table :#{table}/)
    end

    # Check that important node modules were installed
    expect(Pathname.new("#{test_app}/node_modules/shakapacker")).to be_directory

    # Check that the configuration tweaks are applied properly
    expect(File.read("#{test_app}/config/spring.rb")).to match(%r{^require "decidim/spring"})
  end
end

shared_context "with application env vars" do
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
      "DECIDIM_ADMIN_PASSWORD_EXPIRATION_DAYS" => "",
      "DECIDIM_ADMIN_PASSWORD_MIN_LENGTH" => "",
      "DECIDIM_ADMIN_PASSWORD_REPETITION_TIMES" => "",
      "DECIDIM_ADMIN_PASSWORD_STRONG" => "",
      "DECIDIM_DELETE_INACTIVE_USERS_AFTER_DAYS" => "",
      "DECIDIM_MINIMUM_INACTIVITY_PERIOD" => "",
      "DECIDIM_DELETE_INACTIVE_USERS_FIRST_WARNING_DAYS_BEFORE" => "",
      "DECIDIM_DELETE_INACTIVE_USERS_LAST_WARNING_DAYS_BEFORE" => "",
      "DECIDIM_SERVICE_WORKER_ENABLED" => "",
      "RAILS_LOG_LEVEL" => "nonsense",
      "STORAGE_PROVIDER" => ""
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
      "DECIDIM_CORS_ENABLED" => "false",
      "DECIDIM_SERVICE_WORKER_ENABLED" => "false"
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
      "DECIDIM_DOWNLOAD_YOUR_DATA_EXPIRY_TIME" => "2",
      "DECIDIM_THROTTLING_MAX_REQUESTS" => "99",
      "DECIDIM_THROTTLING_PERIOD" => "2",
      "DECIDIM_UNCONFIRMED_ACCESS_FOR" => "3",
      "DECIDIM_SYSTEM_ACCESSLIST_IPS" => "127.0.0.1,172.26.0.1/24",
      "DECIDIM_BASE_UPLOADS_PATH" => "some-path/",
      "DECIDIM_DEFAULT_CSV_COL_SEP" => ",",
      "DECIDIM_CORS_ENABLED" => "true",
      "DECIDIM_SERVICE_WORKER_ENABLED" => "true",
      "DECIDIM_CONSENT_COOKIE_NAME" => ":weird-consent-cookie-name:",
      "DECIDIM_CACHE_KEY_SEPARATOR" => ":",
      "DECIDIM_CACHE_EXPIRATION_TIME" => "33",
      "DECIDIM_STATS_CACHE_EXPIRATION_TIME" => "15",
      "DECIDIM_EXPIRE_SESSION_AFTER" => "45",
      "DECIDIM_ENABLE_REMEMBER_ME" => "",
      "DECIDIM_SESSION_TIMEOUT_INTERVAL" => "33",
      "DECIDIM_FOLLOW_HTTP_X_FORWARDED_HOST" => "true",
      "DECIDIM_MAXIMUM_CONVERSATION_MESSAGE_LENGTH" => "1234",
      "DECIDIM_PASSWORD_SIMILARITY_LENGTH" => "4",
      "DECIDIM_DENIED_PASSWORDS" => "i-do-not-like-this-password, i-do-not,like,this,one,either, password123456",
      "DECIDIM_ALLOW_OPEN_REDIRECTS" => "true",
      "DECIDIM_ADMIN_PASSWORD_EXPIRATION_DAYS" => "93",
      "DECIDIM_ADMIN_PASSWORD_MIN_LENGTH" => "18",
      "DECIDIM_ADMIN_PASSWORD_REPETITION_TIMES" => "8",
      "DECIDIM_ADMIN_PASSWORD_STRONG" => "false",
      "DECIDIM_DELETE_INACTIVE_USERS_AFTER_DAYS" => "365",
      "DECIDIM_MINIMUM_INACTIVITY_PERIOD" => "30",
      "DECIDIM_DELETE_INACTIVE_USERS_FIRST_WARNING_DAYS_BEFORE" => "30",
      "DECIDIM_DELETE_INACTIVE_USERS_LAST_WARNING_DAYS_BEFORE" => "7",
      "RAILS_LOG_LEVEL" => "fatal",
      "RAILS_ASSET_HOST" => "http://assets.example.org",
      "ETHERPAD_SERVER" => "http://a-etherpad-server.com",
      "ETHERPAD_API_KEY" => "an-etherpad-key",
      "ETHERPAD_API_VERSION" => "1.2.2",
      "MAPS_PROVIDER" => "here",
      "MAPS_API_KEY" => "a-maps-api-key",
      "VAPID_PUBLIC_KEY" => "a-vapid-public-key",
      "VAPID_PRIVATE_KEY" => "a-vapid-private-key",
      "STORAGE_PROVIDER" => "test",
      "STORAGE_CDN_HOST" => "https://cdn.example.org",
      "API_SCHEMA_MAX_PER_PAGE" => "31",
      "API_SCHEMA_MAX_COMPLEXITY" => "3001",
      "API_SCHEMA_MAX_DEPTH" => "11",
      "PROPOSALS_PARTICIPATORY_SPACE_HIGHLIGHTED_PROPOSALS_LIMIT" => "6",
      "PROPOSALS_PROCESS_GROUP_HIGHLIGHTED_PROPOSALS_LIMIT" => "5",
      "MEETINGS_UPCOMING_MEETING_NOTIFICATION" => "3",
      "MEETINGS_WAITING_LIST_ENABLED" => "true",
      "MEETINGS_EMBEDDABLE_SERVICES" => "www.youtube.com www.twitch.tv meet.jit.si 8x8.vc",
      "INITIATIVES_CREATION_ENABLED" => "false",
      "INITIATIVES_SIMILARITY_THRESHOLD" => "0.99",
      "INITIATIVES_SIMILARITY_LIMIT" => "10",
      "INITIATIVES_MINIMUM_COMMITTEE_MEMBERS" => "3",
      "INITIATIVES_DEFAULT_SIGNATURE_TIME_PERIOD_LENGTH" => "133",
      "INITIATIVES_DEFAULT_COMPONENTS" => "pages, proposals,budgets",
      "INITIATIVES_FIRST_NOTIFICATION_PERCENTAGE" => "10",
      "INITIATIVES_SECOND_NOTIFICATION_PERCENTAGE" => "70",
      "INITIATIVES_STATS_CACHE_EXPIRATION_TIME" => "7",
      "INITIATIVES_MAX_TIME_IN_VALIDATING_STATE" => "50",
      "INITIATIVES_PRINT_ENABLED" => "false",
      "INITIATIVES_DO_NOT_REQUIRE_AUTHORIZATION" => "true"
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
end

shared_examples_for "an application with configurable env vars" do
  include_context "with application env vars"

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
      %w(decidim download_your_data_expiry_time) => 7,
      %w(decidim throttling_max_requests) => 100,
      %w(decidim throttling_period) => 1,
      %w(decidim unconfirmed_access_for) => 0,
      %w(decidim system_accesslist_ips) => [],
      %w(decidim base_uploads_path) => nil,
      %w(decidim default_csv_col_sep) => ";",
      %w(decidim cors_enabled) => false,
      %w(decidim service_worker_enabled) => true,
      %w(decidim consent_cookie_name) => "decidim-consent",
      %w(decidim cache_key_separator) => "/",
      %w(decidim cache_expiry_time) => 1440,
      %w(decidim stats_cache_expiry_time) => 10,
      %w(decidim expire_session_after) => 30,
      %w(decidim enable_remember_me) => "auto",
      %w(decidim session_timeout_interval) => 10,
      %w(decidim follow_http_x_forwarded_host) => false,
      %w(decidim maximum_conversation_message_length) => 1000,
      %w(decidim password_similarity_length) => 4,
      %w(decidim denied_passwords) => [],
      %w(decidim allow_open_redirects) => false,
      %w(decidim admin_password expiration_days) => 90,
      %w(decidim admin_password min_length) => 15,
      %w(decidim admin_password repetition_times) => 5,
      %w(decidim admin_password strong) => true,
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
      %w(vapid private_key) => nil,
      %w(storage provider) => "local",
      %w(storage cdn_host) => nil,
      %w(decidim api schema_max_per_page) => 50,
      %w(decidim api schema_max_complexity) => 5000,
      %w(decidim api schema_max_depth) => 15,
      %w(decidim proposals participatory_space_highlighted_proposals_limit) => 4,
      %w(decidim proposals process_group_highlighted_proposals_limit) => 3,
      %w(decidim meetings upcoming_meeting_notification) => 2,
      %w(decidim meetings embeddable_services) => [],
      %w(decidim initiatives creation_enabled) => "auto",
      %w(decidim initiatives minimum_committee_members) => 2,
      %w(decidim initiatives default_signature_time_period_length) => 120,
      %w(decidim initiatives default_components) => %w(pages meetings blogs),
      %w(decidim initiatives first_notification_percentage) => 33,
      %w(decidim initiatives second_notification_percentage) => 66,
      %w(decidim initiatives stats_cache_expiration_time) => 5,
      %w(decidim initiatives max_time_in_validating_state) => 60,
      %w(decidim initiatives print_enabled) => "auto",
      %w(decidim initiatives do_not_require_authorization) => false
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
      %w(decidim download_your_data_expiry_time) => 2,
      %w(decidim throttling_max_requests) => 99,
      %w(decidim throttling_period) => 2,
      %w(decidim unconfirmed_access_for) => 3,
      %w(decidim system_accesslist_ips) => ["127.0.0.1", "172.26.0.1/24"],
      %w(decidim base_uploads_path) => "some-path/",
      %w(decidim default_csv_col_sep) => ",",
      %w(decidim cors_enabled) => true,
      %w(decidim service_worker_enabled) => true,
      %w(decidim consent_cookie_name) => ":weird-consent-cookie-name:",
      %w(decidim cache_key_separator) => ":",
      %w(decidim cache_expiry_time) => 33,
      %w(decidim stats_cache_expiry_time) => 15,
      %w(decidim expire_session_after) => 45,
      %w(decidim enable_remember_me) => false,
      %w(decidim session_timeout_interval) => 33,
      %w(decidim follow_http_x_forwarded_host) => true,
      %w(decidim maximum_conversation_message_length) => 1234,
      %w(decidim password_similarity_length) => 4,
      %w(decidim denied_passwords) => ["i-do-not-like-this-password", "i-do-not,like,this,one,either", "password123456"],
      %w(decidim allow_open_redirects) => true,
      %w(decidim admin_password expiration_days) => 93,
      %w(decidim admin_password min_length) => 18,
      %w(decidim admin_password repetition_times) => 8,
      %w(decidim admin_password strong) => false,
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
      %w(vapid private_key) => "a-vapid-private-key",
      %w(storage provider) => "test",
      %w(storage cdn_host) => "https://cdn.example.org",
      %w(decidim api schema_max_per_page) => 31,
      %w(decidim api schema_max_complexity) => 3001,
      %w(decidim api schema_max_depth) => 11,
      %w(decidim proposals participatory_space_highlighted_proposals_limit) => 6,
      %w(decidim proposals process_group_highlighted_proposals_limit) => 5,
      %w(decidim meetings upcoming_meeting_notification) => 3,
      %w(decidim meetings embeddable_services) => %w(www.youtube.com www.twitch.tv meet.jit.si 8x8.vc),
      %w(decidim initiatives creation_enabled) => false,
      %w(decidim initiatives minimum_committee_members) => 3,
      %w(decidim initiatives default_signature_time_period_length) => 133,
      %w(decidim initiatives default_components) => %w(pages proposals budgets),
      %w(decidim initiatives first_notification_percentage) => 10,
      %w(decidim initiatives second_notification_percentage) => 70,
      %w(decidim initiatives stats_cache_expiration_time) => 7,
      %w(decidim initiatives max_time_in_validating_state) => 50,
      %w(decidim initiatives print_enabled) => false,
      %w(decidim initiatives do_not_require_authorization) => true
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
      "maximum_attachment_size" => 10, # 10 megabytes
      "maximum_avatar_size" => 5, # 5 megabytes
      "max_reports_before_hiding" => 3,
      "track_newsletter_links" => true,
      "download_your_data_expiry_time" => 604_800, # 7 days
      "throttling_max_requests" => 100,
      "throttling_period" => 60, # 1 minute
      "unconfirmed_access_for" => 0,
      "system_accesslist_ips" => [],
      "base_uploads_path" => nil,
      "default_csv_col_sep" => ";",
      "cors_enabled" => false,
      "consent_cookie_name" => "decidim-consent",
      "cache_key_separator" => "/",
      "cache_expiry_time" => 86_400, # 1 day
      "stats_cache_expiry_time" => 600, # 10 minutes
      "expire_session_after" => 1800, # 30 minutes
      "enable_remember_me" => true,
      "session_timeout_interval" => 10,
      "follow_http_x_forwarded_host" => false,
      "maximum_conversation_message_length" => 1000,
      "password_similarity_length" => 4,
      "denied_passwords" => [],
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
      "maximum_attachment_size" => 25, # 25 megabytes
      "maximum_avatar_size" => 11, # 11 megabytes
      "max_reports_before_hiding" => 4,
      "track_newsletter_links" => false,
      "download_your_data_expiry_time" => 172_800, # 2 days
      "throttling_max_requests" => 99,
      "throttling_period" => 120, # 2 minutes
      "unconfirmed_access_for" => 259_200, # 3 days
      "system_accesslist_ips" => ["127.0.0.1", "172.26.0.1/24"],
      "base_uploads_path" => "some-path/",
      "default_csv_col_sep" => ",",
      "cors_enabled" => true,
      "consent_cookie_name" => ":weird-consent-cookie-name:",
      "cache_key_separator" => ":",
      "cache_expiry_time" => 1980,
      "stats_cache_expiry_time" => 900,
      "expire_session_after" => 2700, # 45 minutes
      "enable_remember_me" => false,
      "session_timeout_interval" => 33,
      "follow_http_x_forwarded_host" => true,
      "maximum_conversation_message_length" => 1234,
      "password_similarity_length" => 4,
      "denied_passwords" => ["i-do-not-like-this-password", "i-do-not,like,this,one,either", "password123456"],
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
          "url" => "https://image.maps.hereapi.com/mia/v3/base/mc/overlay"
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
          "url" => "https://image.maps.hereapi.com/mia/v3/base/mc/overlay"
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

  let(:api_initializer_off) do
    {
      "schema_max_per_page" => 50,
      "schema_max_complexity" => 5000,
      "schema_max_depth" => 15
    }
  end

  let(:api_initializer_on) do
    {
      "schema_max_per_page" => 31,
      "schema_max_complexity" => 3001,
      "schema_max_depth" => 11
    }
  end

  let(:proposals_initializer_off) do
    {
      "participatory_space_highlighted_proposals_limit" => 4,
      "process_group_highlighted_proposals_limit" => 3
    }
  end

  let(:proposals_initializer_on) do
    {
      "participatory_space_highlighted_proposals_limit" => 6,
      "process_group_highlighted_proposals_limit" => 5
    }
  end

  let(:meetings_initializer_off) do
    {
      "upcoming_meeting_notification" => 172_800, # 2.days
      "embeddable_services" => %w(www.youtube.com www.twitch.tv meet.jit.si)
    }
  end

  let(:meetings_initializer_on) do
    {
      "upcoming_meeting_notification" => 259_200, # 3.days
      "embeddable_services" => %w(www.youtube.com www.twitch.tv meet.jit.si 8x8.vc)
    }
  end

  # The logs settings have changed between Rails 6.0 abd 6.1 and this may be here
  # https://github.com/rails/rails/commit/73079940111e8b85bf87953e5ef9fafeece5b5da
  let(:rails_off) do
    {
      "Rails.logger.level" => 1,
      "Rails.application.config.log_level" => "info",
      "Rails.application.config.action_controller.asset_host" => nil,
      "Rails.application.config.active_storage.service" => "local",
      "Decidim::EngineRouter.new(nil, {}).send(:configured_default_url_options)" => { "protocol" => "https" }
    }
  end

  let(:rails_on) do
    {
      "Rails.logger.level" => 4,
      "Rails.application.config.log_level" => "fatal",
      "Rails.application.config.action_controller.asset_host" => "http://assets.example.org",
      "Rails.application.config.active_storage.service" => "test",
      "Decidim::AssetRouter::Storage.new(nil).send(:default_options)" => { "host" => "https://cdn.example.org" },
      "Decidim::Api::Schema.default_max_page_size" => 31,
      "Decidim::Api::Schema.max_complexity" => 3001,
      "Decidim::Api::Schema.max_depth" => 11
    }
  end

  # This is using a big example to avoid recreating the application every time
  it "env vars generate secrets application" do
    expect(result[1]).to be_success, result[0]

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

    # Test onto the initializer when ENV vars are set to OpenStreetMap configuration
    json_on = initializer_config_for(test_app, env_maps_osm)
    initializer_maps_osm.each do |key, value|
      current = json_on[key]
      expect(current).to eq(value), "Initializer (#{key}) = (#{current}) expected to match Env:Maps OSM (#{value})"
    end

    # Test onto the initializer when ENV vars are set to OpenStreetMap-HERE mix configuration
    json_on = initializer_config_for(test_app, env_maps_mix)
    initializer_maps_mix.each do |key, value|
      current = json_on[key]
      expect(current).to eq(value), "Initializer (#{key}) = (#{current}) expected to match Env:Maps MIX (#{value})"
    end

    # Test onto the initializer with ENV vars OFF for the API module
    json_off = initializer_config_for(test_app, env_off, "Decidim::Api")
    api_initializer_off.each do |key, value|
      current = json_off[key]
      expect(current).to eq(value), "API Initializer (#{key}) = (#{current}) expected to match Env (#{value})"
    end

    # Test onto the initializer with ENV vars ON for the API module
    json_on = initializer_config_for(test_app, env_on, "Decidim::Api")
    api_initializer_on.each do |key, value|
      current = json_on[key]
      expect(current).to eq(value), "API Initializer (#{key}) = (#{current}) expected to match Env (#{value})"
    end

    # Test onto the initializer with ENV vars OFF for the Proposals module
    json_off = initializer_config_for(test_app, env_off, "Decidim::Proposals")
    proposals_initializer_off.each do |key, value|
      current = json_off[key]
      expect(current).to eq(value), "Proposals Initializer (#{key}) = (#{current}) expected to match Env (#{value})"
    end

    # Test onto the initializer with ENV vars ON for the Proposals module
    json_on = initializer_config_for(test_app, env_on, "Decidim::Proposals")
    proposals_initializer_on.each do |key, value|
      current = json_on[key]
      expect(current).to eq(value), "Proposals Initializer (#{key}) = (#{current}) expected to match Env (#{value})"
    end

    # Test onto the initializer with ENV vars OFF for the Meetings module
    json_off = initializer_config_for(test_app, env_off, "Decidim::Meetings")
    meetings_initializer_off.each do |key, value|
      current = json_off[key]
      expect(current).to eq(value), "Meetings Initializer (#{key}) = (#{current}) expected to match Env (#{value})"
    end

    # Test onto the initializer with ENV vars ON for the Meetings module
    json_on = initializer_config_for(test_app, env_on, "Decidim::Meetings")
    meetings_initializer_on.each do |key, value|
      current = json_on[key]
      expect(current).to eq(value), "Meetings Initializer (#{key}) = (#{current}) expected to match Env (#{value})"
    end

    # Test onto some extra Rails configs when ENV vars are empty or undefined
    rails_off.each do |key, value|
      current = rails_value(key, test_app, env_off)
      expect(current).to eq(value), "Rails config (#{key}) = (#{current}) expected to match Env:OFF (#{value})"
    end

    # Test onto some extra Rails configs when ENV vars are set
    rails_on.each do |key, value|
      current = rails_value(key, test_app, env_on)
      expect(current).to eq(value), "Rails config (#{key}) = (#{current}) expected to match Env:ON (#{value})"
    end
  end
end

shared_examples_for "an application with extra configurable env vars" do
  include_context "with application env vars"

  let(:initiatives_initializer_off) do
    {
      "creation_enabled" => true,
      "minimum_committee_members" => 2,
      "default_signature_time_period_length" => 120,
      "default_components" => %w(pages meetings blogs),
      "first_notification_percentage" => 33,
      "second_notification_percentage" => 66,
      "stats_cache_expiration_time" => 300, # 5.minutes
      "max_time_in_validating_state" => 5_184_000, # 60.days
      "print_enabled" => false,
      "do_not_require_authorization" => false
    }
  end

  let(:initiatives_initializer_on) do
    {
      "creation_enabled" => false,
      "minimum_committee_members" => 3,
      "default_signature_time_period_length" => 133,
      "default_components" => %w(pages proposals budgets),
      "first_notification_percentage" => 10,
      "second_notification_percentage" => 70,
      "stats_cache_expiration_time" => 420, # 7.minutes
      "max_time_in_validating_state" => 4_320_000, # 50.days
      "print_enabled" => false,
      "do_not_require_authorization" => true
    }
  end

  it "env vars generate secrets application" do
    expect(result[1]).to be_success, result[0]

    # Test onto the initializer with ENV vars OFF for the Initiatives module
    json_off = initializer_config_for(test_app, env_off, "Decidim::Initiatives")
    initiatives_initializer_off.each do |key, value|
      current = json_off[key]
      expect(current).to eq(value), "Initiatives Initializer (#{key}) = (#{current}) expected to match Env (#{value})"
    end

    # Test onto the initializer with ENV vars ON for the Initiatives module
    json_on = initializer_config_for(test_app, env_on, "Decidim::Initiatives")
    initiatives_initializer_on.each do |key, value|
      current = json_on[key]
      expect(current).to eq(value), "Initiatives Initializer (#{key}) = (#{current}) expected to match Env (#{value})"
    end
  end
end

shared_examples_for "an application with wrong cloud storage options" do
  it "creating fails" do
    expect(result[1]).not_to be_success, result[0]
  end
end

shared_examples_for "an application with cloud storage gems" do
  let(:services) do
    %w(local s3 gcs azure)
  end
  let(:storage_envs) do
    {
      "RAILS_ENV" => "production",
      "AWS_ACCESS_KEY_ID" => "my-aws-id",
      "AWS_SECRET_ACCESS_KEY" => "my-aws-secret",
      "AWS_REGION" => "eu-west-1",
      # "AWS_ENDPOINT" => "https://s3.amazonaws.com",
      "AWS_BUCKET" => "test",
      "AZURE_STORAGE_ACCOUNT_NAME" => "test",
      "AZURE_STORAGE_ACCESS_KEY" => "dGVzdA==\n", # Base64 of "test"
      "AZURE_CONTAINER" => "test"
    }
  end

  it "includes cloud storage gems in the Gemfile" do
    expect(result[1]).to be_success, result[0]

    expect(File.read("#{test_app}/Gemfile"))
      .to match(/gem ["']+aws-sdk-s3["']+/)
      .and match(/gem ["']+azure-storage-blob["']+/)
      .and match(/gem ["']+google-cloud-storage["']+/)

    services.each do |service|
      current = rails_value("Rails.application.config.active_storage.service", test_app, storage_envs.merge({ "STORAGE_PROVIDER" => service }))
      expect(current).to eq(service), "Rails storage service (#{current}) expected to match provider (#{service})"
    end
  end
end

shared_examples_for "an application with storage and queue gems" do
  let(:queue_envs_off) do
    {
      "RAILS_ENV" => "production"
    }
  end
  let(:queue_envs_on) do
    {
      "RAILS_ENV" => "production",
      "QUEUE_ADAPTER" => "sidekiq",
      "SIDEKIQ_CONCURRENCY" => "11"
    }
  end

  it "includes storage and queue gems in the Gemfile" do
    expect(result[1]).to be_success, result[0]

    expect(File.read("#{test_app}/Gemfile"))
      .to match(/gem ["']+aws-sdk-s3["']+/)
      .and match(/gem ["']+sidekiq["']+/)

    current = rails_value("Rails.application.config.active_job.queue_adapter", test_app, queue_envs_off)
    expect(current).to eq("async"), "sidekiq queue (#{current}) expected to be async"

    current = rails_value("Rails.application.config.active_job.queue_adapter", test_app, queue_envs_on)
    expect(current).to eq("sidekiq"), "sidekiq queue (#{current}) expected to be sidekiq"
    current = rails_value("YAML.load(ERB.new(IO.read(\"config/sidekiq.yml\")).result)", test_app, queue_envs_off)
    expect(current["concurrency"]).to eq(5), "sidekiq concurrency (#{current["concurrency"]}) expected to eq 5"

    current = rails_value("YAML.load(ERB.new(IO.read(\"config/sidekiq.yml\")).result)", test_app, queue_envs_on)
    expect(current["concurrency"]).to eq(11), "sidekiq concurrency (#{current["concurrency"]}) expected to eq 11"

    queues = %w(mailers vote_reminder reminders default newsletter newsletters_opt_in conference_diplomas events translations user_report block_user exports
                close_meeting_reminder)
    expect(current["queues"].flatten).to include(*queues), "sidekiq queues (#{current["queues"].flatten}) expected to contain (#{queues})"
  end
end

def initializer_config_for(path, env, mod = "Decidim")
  JSON.parse cmd_capture(path, "bin/rails runner 'puts #{mod}.config.to_json'", env:)
end

def rails_value(value, path, env)
  JSON.parse cmd_capture(path, "bin/rails runner 'puts #{value}.to_json'", env:)
end

def repo_root
  File.expand_path(File.join("..", "..", "..", "..", ".."), __dir__)
end

def cmd_capture(path, cmd, env: {})
  Bundler.with_unbundled_env do
    Decidim::GemManager.new(path).capture(cmd, env:, with_stderr: false)[0]
  end
end
