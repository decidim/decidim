# frozen_string_literal: true

require "decidim/rails"
require "active_support/all"
require "action_view/railtie"

require "pg"
require "redis"

require "acts_as_list"
require "devise"
require "devise-i18n"
require "devise_invitable"
require "active_link_to"
require "rails-i18n"
require "date_validator"
require "file_validators"
require "omniauth"
require "omniauth-facebook"
require "omniauth-twitter"
require "omniauth-google-oauth2"
require "omniauth/rails_csrf_protection"
require "invisible_captcha"
require "premailer/rails"
require "premailer/adapter/decidim"
require "geocoder"
require "paper_trail"
require "cells/rails"
require "cells-erb"
require "cell/partial"
require "kaminari"
require "doorkeeper"
require "doorkeeper-i18n"
require "batch-loader"
require "mime-types"
require "diffy"
require "ransack"
require "wisper"
require "chartkick"
require "shakapacker"

require "decidim/api"
require "decidim/core/content_blocks/registry_manager"
require "decidim/core/menu"
require "decidim/middleware/strip_x_forwarded_host"
require "decidim/middleware/static_dispatcher"
require "decidim/middleware/current_organization"
require "decidim/webpacker"

module Decidim
  module Core
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim
      engine_name "decidim"

      initializer "decidim_core.register_icons", after: "decidim_core.add_social_share_services" do
        Decidim.icons.register(name: "qr-code-line", icon: "qr-code-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "phone-line", icon: "phone-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "more-2-fill", icon: "more-2-fill", category: "system", description: "Resource Action button", engine: :core)
        Decidim.icons.register(name: "more-fill", icon: "more-fill", category: "system", description: "Resource Action button", engine: :core)
        Decidim.icons.register(name: "upload-cloud-2-line", icon: "upload-cloud-2-line", category: "system",
                               description: "Upload cloud 2 line used in attachments form", engine: :core)
        Decidim.icons.register(name: "arrow-right-line", icon: "arrow-right-line", category: "system",
                               description: "Arrow right line icon used in attachments form", engine: :core)
        Decidim.icons.register(name: "arrow-left-s-fill", icon: "arrow-left-s-fill", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "flag-line", icon: "flag-line", category: "system", description: "Flag line icon", engine: :core)
        Decidim.icons.register(name: "check-line", icon: "check-line", category: "system", description: "Check icon", engine: :core)
        Decidim.icons.register(name: "question-line", icon: "question-line", category: "system", description: "Question icon", engine: :core)
        Decidim.icons.register(name: "close-line", icon: "close-line", category: "system", description: "Close icon", engine: :core)
        Decidim.icons.register(name: "save-line", icon: "save-line", category: "system", description: "Save icon", engine: :core)
        Decidim.icons.register(name: "search-line", icon: "search-line", category: "system", description: "Search icon", engine: :core)
        Decidim.icons.register(name: "timer-line", icon: "timer-line", category: "system", description: "Timer icon", engine: :core)
        Decidim.icons.register(name: "arrow-down-s-line", icon: "arrow-down-s-line", category: "system", description: "Arrow down icon", engine: :core)
        Decidim.icons.register(name: "arrow-up-s-line", icon: "arrow-up-s-line", category: "system", description: "Arrow up icon", engine: :core)
        Decidim.icons.register(name: "road-map-line", icon: "road-map-line", category: "system", description: "Road map icon", engine: :core)
        Decidim.icons.register(name: "bubble-chart-line", icon: "bubble-chart-line", category: "system", description: "Road map icon", engine: :core)
        Decidim.icons.register(name: "user-smile-line", icon: "user-smile-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "account-circle-line", icon: "account-circle-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "notification-3-line", icon: "notification-3-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "mail-send-line", icon: "mail-send-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "logout-box-r-line", icon: "logout-box-r-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "menu-line", icon: "menu-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "home-2-line", icon: "home-2-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "global-line", icon: "global-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "creative-commons-line", icon: "creative-commons-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "creative-commons-by-line", icon: "creative-commons-by-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "creative-commons-sa-line", icon: "creative-commons-sa-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "delete-bin-line", icon: "delete-bin-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "loader-3-line", icon: "loader-3-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "share-line", icon: "share-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "file-copy-line", icon: "file-copy-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "check-double-line", icon: "check-double-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "arrow-drop-down-line", icon: "arrow-drop-down-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "login-box-line", icon: "login-box-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "direction-line", icon: "direction-line", category: "system", description: "", engine: :core)

        Decidim.icons.register(name: "newspaper-line", icon: "newspaper-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "alert-line", icon: "alert-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "checkbox-circle-line", icon: "checkbox-circle-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "equalizer-line", icon: "equalizer-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "dashboard-line", icon: "dashboard-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "information-line", icon: "information-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "question-answer-line", icon: "question-answer-line", category: "system", description: "", engine: :core)

        Decidim.icons.register(name: "account-pin-circle-line", icon: "account-pin-circle-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "award-line", icon: "award-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "eye-2-line", icon: "eye-2-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "eye-close", icon: "eye-close-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "group-line", icon: "group-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "team-line", icon: "team-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "apps-2-line", icon: "apps-2-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "chat-1-line", icon: "chat-1-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "discuss-line", icon: "discuss-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "lightbulb-flash-line", icon: "lightbulb-flash-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "map-pin-line", icon: "map-pin-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "pen-nib-line", icon: "pen-nib-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "pencil-line", icon: "pencil-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "close-circle-line", icon: "close-circle-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "contacts-line", icon: "contacts-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "user-settings-line", icon: "user-settings-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "user-follow-line", icon: "user-follow-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "user-star-line", icon: "user-star-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "user-add-line", icon: "user-add-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "share-forward-line", icon: "share-forward-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "star-s-fill", icon: "star-s-fill", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "arrow-left-line", icon: "arrow-left-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "file-3-line", icon: "file-3-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "play-fill", icon: "play-fill", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "fingerprint-line", icon: "fingerprint-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "list-check-2", icon: "list-check-2", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "notification-3-fill", icon: "notification-3-fill", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "pages-line", icon: "pages-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "mail-add-line", icon: "mail-add-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "tools-line", icon: "tools-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "eye-line", icon: "eye-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "government-line", icon: "government-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "mail-line", icon: "mail-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "live-line", icon: "live-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "home-gear-line", icon: "home-gear-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "check-double-fill", icon: "check-double-fill", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "file-list-3-line", icon: "file-list-3-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "price-tag-3-line", icon: "price-tag-3-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "time-line", icon: "time-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "calendar-line", icon: "calendar-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "question-mark", icon: "question-mark", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "arrow-left-s-line", icon: "arrow-left-s-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "phone", icon: "phone", category: "system", description: "", engine: :core)

        Decidim.icons.register(name: "user-line", icon: "user-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "mic-line", icon: "mic-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "coin-line", icon: "coin-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "external-link-line", icon: "external-link-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "arrow-down-s-fill", icon: "arrow-down-s-fill", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "arrow-up-s-fill", icon: "arrow-up-s-fill", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "treasure-map-line", icon: "treasure-map-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "chat-new-line", icon: "chat-new-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "history", icon: "history-line", category: "system", description: "History timeline", engine: :core)
        Decidim.icons.register(name: "survey-line", icon: "survey-line", category: "system", description: "Survey line", engine: :core)
        Decidim.icons.register(name: "draft-line", icon: "draft-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "user-voice-line", icon: "user-voice-line", category: "system", description: "", engine: :core)

        # Attachments
        Decidim.icons.register(name: "file-text-line", icon: "file-text-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "file-upload-line", icon: "file-upload-line", category: "documents", description: "File upload", engine: :core)
        Decidim.icons.register(name: "scales-2-line", icon: "scales-2-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "image-line", icon: "image-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "error-warning-line", icon: "error-warning-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "folder-open-line", icon: "folder-open-line", category: "system", description: "", engine: :core)

        Decidim.icons.register(name: "dislike-line", icon: "dislike-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "chat-poll-line", icon: "chat-poll-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "git-branch-line", icon: "git-branch-line", category: "system", description: "", engine: :core)

        Decidim.icons.register(name: "calendar-todo-line", icon: "calendar-todo-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "home-8-line", icon: "home-8-line", category: "system", description: "", engine: :core)

        Decidim.icons.register(name: "like", icon: "heart-line", description: "Like", category: "action", engine: :core)
        Decidim.icons.register(name: "dislike", icon: "heart-fill", description: "Dislike", category: "action", engine: :core)
        Decidim.icons.register(name: "drag-move-2-line", icon: "drag-move-2-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "drag-move-2-fill", icon: "drag-move-2-fill", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "draggable", icon: "draggable", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "login-circle-line", icon: "login-circle-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "list-check", icon: "list-check", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "add-fill", icon: "add-fill", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "clipboard-line", icon: "clipboard-line", category: "system", description: "", engine: :initiatives)
        Decidim.icons.register(name: "user-forbid-line", icon: "user-forbid-line", category: "system", description: "", engine: :core)

        # Refactor later: Some of the icons here are duplicated, and it would be a greater refactor to remove the duplicates
        Decidim.icons.register(name: "Decidim::Amendment", icon: "git-branch-line", category: "activity", description: "Amendment", engine: :core)
        Decidim.icons.register(name: "Decidim::Category", icon: "price-tag-3-line", description: "Category", category: "activity", engine: :core)
        Decidim.icons.register(name: "Decidim::Scope", icon: "scan-line", description: "Scope", category: "activity", engine: :core)
        Decidim.icons.register(name: "Decidim::Taxonomy", icon: "scan-line", description: "Taxonomy", category: "activity", engine: :core)
        Decidim.icons.register(name: "Decidim::User", icon: "user-line", description: "User", category: "activity", engine: :core)
        Decidim.icons.register(name: "follow", icon: "notification-3-line", description: "Follow", category: "action", engine: :core)
        Decidim.icons.register(name: "unfollow", icon: "notification-3-fill", description: "Unfollow", category: "action", engine: :core)
        Decidim.icons.register(name: "share", icon: "share-line", description: "Share", category: "action", engine: :core)
        Decidim.icons.register(name: "nickname", icon: "account-pin-circle-line", description: "Nickname", category: "profile", engine: :core)
        Decidim.icons.register(name: "badges", icon: "award-line", description: "Badges", category: "profile", engine: :core)
        Decidim.icons.register(name: "profile", icon: "team-line", description: "Groups", category: "profile", engine: :core)
        Decidim.icons.register(name: "user_group", icon: "team-line", description: "Groups", category: "profile", engine: :core)
        Decidim.icons.register(name: "link", icon: "link", description: "web / URL", category: "profile", engine: :core)
        Decidim.icons.register(name: "unlink", icon: "link-unlink-m", description: "Unlink", category: "profile", engine: :core)
        Decidim.icons.register(name: "following", icon: "eye-2-line", description: "Following", category: "profile", engine: :core)
        Decidim.icons.register(name: "activity", icon: "bubble-chart-line", description: "Activity", category: "profile", engine: :core)
        Decidim.icons.register(name: "followers", icon: "group-line", description: "Followers", category: "profile", engine: :core)
        Decidim.icons.register(name: "documents", icon: "file-text-line", description: "Document", category: "documents", engine: :core)
        Decidim.icons.register(name: "folder_open", icon: "folder-open-line", description: "Folder open", category: "documents", engine: :core)
        Decidim.icons.register(name: "folder_close", icon: "folder-line", description: "Folder close", category: "documents", engine: :core)
        Decidim.icons.register(name: "document_weight", icon: "scales-2-line", description: "Doc. weight (kb/mb)", category: "documents", engine: :core)
        Decidim.icons.register(name: "document_download", icon: "download-line", description: "Download", category: "documents", engine: :core)
        Decidim.icons.register(name: "images", icon: "image-line", description: "Images", category: "documents", engine: :core)
        Decidim.icons.register(name: "all", icon: "apps-2-line", description: "All", category: "other", engine: :core)
        Decidim.icons.register(name: "other", icon: "question-line", description: "Other", category: "other", engine: :core)

        # social icons
        Decidim.icons.register(name: "wechat-line", icon: "wechat-line", category: "social icon", description: "", engine: :core)
        Decidim.icons.register(name: "linkedin-box-fill", icon: "linkedin-box-fill", category: "social icon", description: "", engine: :core)
        Decidim.icons.register(name: "twitter-x-line", icon: "twitter-x-line", category: "social icon", description: "", engine: :core)
        Decidim.icons.register(name: "whatsapp-line", icon: "whatsapp-line", category: "social icon", description: "", engine: :core)
        Decidim.icons.register(name: "telegram-line", icon: "telegram-line", category: "social icon", description: "", engine: :core)
        Decidim.icons.register(name: "twitter-x-fill", icon: "twitter-x-fill", category: "social icon", description: "", engine: :core)
        Decidim.icons.register(name: "google-fill", icon: "google-fill", category: "social icon", description: "", engine: :core)
        Decidim.icons.register(name: "facebook-fill", icon: "facebook-fill", category: "social icon", description: "", engine: :core)
        Decidim.icons.register(name: "instagram-line", icon: "instagram-line", category: "social icon", description: "", engine: :core)
        Decidim.icons.register(name: "youtube-line", icon: "youtube-line", category: "social icon", description: "", engine: :core)
        Decidim.icons.register(name: "github-fill", icon: "github-fill", category: "social icon", description: "", engine: :core)
        Decidim.icons.register(name: "facebook-circle-line", icon: "facebook-circle-line", category: "social icon", description: "", engine: :core)
      end

      initializer "decidim_core.patch_webpacker", before: "shakapacker.version_checker" do
        ENV["SHAKAPACKER_CONFIG"] = Decidim::Webpacker.configuration.configuration_file
      end

      # Rails 7.0 default is vips, but
      # The `:mini_magick` option is not deprecated; it is fine to keep using it.
      # And we are going to use it while migrating rails application
      initializer "decidim_core.active_storage_variant_processor" do |app|
        app.config.active_storage.variant_processor = :mini_magick
      end

      initializer "decidim_core.active_storage_method_patch" do |_app|
        if Rails::VERSION::MAJOR < 8
          # This is a manual bugfix of https://github.com/rails/rails/pull/51931
          module Attachment
            def named_variants
              record.attachment_reflections[name]&.named_variants || {}
            end
          end

          ActiveSupport.on_load(:active_storage_attachment) { prepend Attachment }
        else
          ActiveSupport::Deprecation.warn("Remove decidim_core.active_storage_method_patch initializer from #{__FILE__}")
        end
      end

      initializer "decidim_core.action_controller" do |_app|
        config.to_prepare do
          ActiveSupport.on_load :action_controller do
            helper Decidim::LayoutHelper if respond_to?(:helper)
          end
        end
      end

      initializer "decidim_core.active_support" do |app|
        # Rails 7.0 default
        app.config.active_support.disable_to_s_conversion = true
        app.config.active_support.cache_format_version = 7.0
      end

      initializer "decidim_core.action_mailer" do |app|
        app.config.action_mailer.deliver_later_queue_name = :mailers
      end

      initializer "decidim_core.active_storage", before: "active_storage.configs" do |app|
        next if app.config.active_storage.service_urls_expire_in.present?

        # Ensure that the ActiveStorage URLs are valid long enough because with
        # the default configuration they would expire in 5 minutes which is a
        # problem:
        #   a) for the backend blob URL replacement
        #   and
        #   b) for caching
        #
        # Note the limitations for each storage service regarding the signed URL
        # expiration times. This limitation has to be also considered when
        # defining a caching strategy, otherwise e.g. images or files may not
        # display correctly when caching is enabled.
        #
        # ActiveStorage disk service (default): no limitation
        #
        # S3: maximum is 7 days from the creation of the URL
        # https://docs.aws.amazon.com/AmazonS3/latest/userguide/PresignedUrlUploadObject.html
        #
        # Google: maximum is 7 days (604800 seconds)
        # https://cloud.google.com/storage/docs/access-control/signed-urls
        #
        # Azure: no limitation
        # https://learn.microsoft.com/en-us/azure/storage/common/storage-sas-overview#best-practices-when-using-sas
        app.config.active_storage.service_urls_expire_in = 7.days
      end

      initializer "decidim_core.signed_global_id", after: "global_id" do |app|
        next if app.config.global_id.fetch(:expires_in, nil).present?

        config.after_initialize do
          SignedGlobalID.expires_in = nil
        end
      end

      initializer "decidim_core.middleware" do |app|
        if app.config.public_file_server.enabled
          headers = app.config.public_file_server.headers || {}

          app.config.middleware.swap(
            ActionDispatch::Static,
            Decidim::Middleware::StaticDispatcher,
            app.paths["public"].first,
            index: app.config.public_file_server.index_name,
            headers:
          )
        end

        app.config.middleware.insert_before Warden::Manager, Decidim::Middleware::CurrentOrganization
        app.config.middleware.insert_before Warden::Manager, Decidim::Middleware::StripXForwardedHost
        app.config.middleware.use BatchLoader::Middleware
      end

      initializer "decidim_core.param_filtering" do |app|
        app.config.filter_parameters += [:document_number, :postal_code, :mobile_phone_number]
      end

      initializer "decidim_core.default_form_builder" do |_app|
        ActionView::Base.default_form_builder = Decidim::FormBuilder
      end

      initializer "decidim_core.exceptions_app" do |app|
        app.config.exceptions_app = Decidim::Core::Engine.routes
      end

      initializer "decidim_core.direct_uploader_paths", after: "decidim_core.exceptions_app" do |_app|
        config.to_prepare do
          ActiveStorage::DirectUploadsController.include Decidim::DirectUpload
        end
      end

      initializer "decidim_core.locales" do |app|
        app.config.i18n.fallbacks = true
      end

      initializer "decidim_core.graphql_api" do
        Decidim::Api::QueryType.include Decidim::QueryExtensions

        Decidim::Api.add_orphan_type Decidim::Core::UserType
      end

      initializer "decidim_core.ransack" do
        Ransack.configure do |config|
          # Avoid turning parameter values such as user_id[]=1&user_id[]=2 into
          # { user_id: [true, "2"] }. This option allows us to handle the type
          # conversions manually instead for each case.
          # See: https://github.com/activerecord-hackery/ransack/issues/593
          # See: https://github.com/activerecord-hackery/ransack/pull/742
          config.sanitize_custom_scope_booleans = false

          # Datetime predicates
          value_presence = ->(v) { v.present? }
          minute_start = ->(v) { v.to_time.strftime("%Y-%m-%dT%H:%M:00") }
          minute_end = ->(v) { v.to_time.strftime("%Y-%m-%dT%H:%M:59") }
          integer_presence = ->(v) { v.to_i.positive? }
          array_cast = ->(v) { Arel.sql("ARRAY[#{v.to_i}]") }
          config.add_predicate("dtgt", arel_predicate: "gt", formatter: minute_start, validator: value_presence, type: :datetime)
          config.add_predicate("dtlt", arel_predicate: "lt", formatter: minute_end, validator: value_presence, type: :datetime)
          config.add_predicate("dtgteq", arel_predicate: "gteq", formatter: minute_start, validator: value_presence, type: :datetime)
          config.add_predicate("dtlteq", arel_predicate: "lteq", formatter: minute_end, validator: value_presence, type: :datetime)
          # this allows to search for an integer inside a column that is an array
          config.add_predicate("contains", arel_predicate: "contains", formatter: array_cast, validator: integer_presence)
        end
      end

      initializer "decidim_core.i18n_exceptions" do |app|
        app.config.i18n.raise_on_missing_translations = true unless Rails.env.production?
      end

      initializer "decidim_core.geocoding", after: :load_config_initializers do
        Geocoder.configure(Decidim.geocoder) if Decidim.geocoder.present?
      end

      initializer "decidim_core.geocoding_extensions", after: "geocoder.insert_into_active_record" do
        # Include it in ActiveRecord base in order to apply it to all models
        # that may be using the `geocoded_by` or `reverse_geocoded_by` class
        # methods injected by the Geocoder gem.
        ActiveSupport.on_load(:active_record) { include Decidim::Geocodable }
      end

      initializer "decidim_core.maps" do
        Decidim::Map.register_category(:dynamic, Decidim::Map::Provider::DynamicMap)
        Decidim::Map.register_category(:static, Decidim::Map::Provider::StaticMap)
        Decidim::Map.register_category(:geocoding, Decidim::Map::Provider::Geocoding)
        Decidim::Map.register_category(:autocomplete, Decidim::Map::Provider::Autocomplete)
      end

      # This keeps backwards compatibility with the old style of map
      # configuration through Decidim.geocoder.
      initializer "decidim_core.maps_legacysupport", after: :load_config_initializers do
        next if Decidim.maps.present?
        next if Decidim.geocoder.blank?

        legacy_api_key ||= if Decidim.geocoder[:here_api_key].present?
                             Decidim.geocoder.fetch(:here_api_key)
                           elsif Decidim.geocoder[:here_app_id].present?
                             [
                               Decidim.geocoder.fetch(:here_app_id),
                               Decidim.geocoder.fetch(:here_app_code)
                             ]
                           end

        next unless legacy_api_key

        ActiveSupport::Deprecation.warn(
          <<~DEPRECATION.strip
            Configuring maps functionality has changed.

            Please update your current Decidim.geocoder configurations to the following format:

              Decidim.configure do |config|
                config.maps = {
                  provider: :here,
                  api_key: Decidim::Env.new("MAPS_STATIC_API_KEY", Decidim::Env.new("MAPS_API_KEY", nil)).to_s,
                  static: { url: "#{Decidim.geocoder.fetch(:static_map_url)}" }
                }
              end
          DEPRECATION
        )
        Decidim.configure do |config|
          config.maps = {
            provider: :here,
            api_key: legacy_api_key,
            static: {
              url: Decidim.geocoder.fetch(:static_map_url)
            }
          }
        end
      end

      initializer "decidim_core.stats" do
        Decidim.stats.register :users_count,
                               priority: StatsRegistry::HIGH_PRIORITY,
                               icon_name: "user-line",
                               tooltip_key: "users_count_tooltip" do |organization, start_at, end_at|
          StatsUsersCount.for(organization, start_at, end_at)
        end
      end

      initializer "decidim_core.menu" do
        Decidim::Core::Menu.register_menu!
        Decidim::Core::Menu.register_mobile_menu!
        Decidim::Core::Menu.register_user_menu!
      end

      initializer "decidim_core.notifications" do
        config.after_initialize do
          Decidim::EventsManager.subscribe_events!
        end
      end

      initializer "decidim_core.validators" do
        config.to_prepare do
          # Decidim overrides to the file content type validator
          require File.expand_path("#{Decidim::Core::Engine.root}/app/validators/file_content_type_validator")
        end
      end

      initializer "decidim_core.content_processors" do |_app|
        Decidim.configure do |config|
          config.content_processors += [:user, :hashtag, :link, :blob, :mention_resource]
        end
      end

      initializer "decidim_core.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Core::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Core::Engine.root}/app/cells/amendable")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Core::Engine.root}/app/views") # for partials
      end

      initializer "decidim_core.doorkeeper", before: "doorkeeper.params.filter" do
        Doorkeeper.configure do
          orm :active_record

          # This block will be called to check whether the resource owner is authenticated or not.
          resource_owner_authenticator do
            current_user || redirect_to(new_user_session_path)
          end

          # The controller Doorkeeper::ApplicationController inherits from.
          # Defaults to ActionController::Base.
          # https://github.com/doorkeeper-gem/doorkeeper#custom-base-controller
          base_controller "Decidim::ApplicationController"

          # Provide support for an owner to be assigned to each registered application (disabled by default)
          # Optional parameter confirmation: true (default false) if you want to enforce ownership of
          # a registered application
          # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
          enable_application_owner confirmation: false

          # Define access token scopes for your provider
          # For more information go to
          # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
          default_scopes :public
          optional_scopes []

          # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
          # by default in non-development environments). OAuth2 delegates security in
          # communication to the HTTPS protocol so it is wise to keep this enabled.
          #
          # Callable objects such as proc, lambda, block or any object that responds to
          # #call can be used in order to allow conditional checks (to allow non-SSL
          # redirects to localhost for example).
          #
          force_ssl_in_redirect_uri !Rails.env.development?

          # WWW-Authenticate Realm (default "Doorkeeper").
          realm "Decidim"
        end
      end

      initializer "decidim_core.oauth_inflections" do
        ActiveSupport::Inflector.inflections do |inflect|
          inflect.acronym "OAuth"
        end
      end

      initializer "decidim_core.ssl_and_hsts" do
        Rails.application.configure do
          config.force_ssl = Decidim.config.force_ssl
        end
      end

      initializer "decidim_core.disable_rack_runtime" do
        Rails.application.configure do
          config.middleware.delete Rack::Runtime
        end
      end

      initializer "decidim_core.session_store" do |app|
        next if app.config.session_store?

        app.config.session_store :cookie_store, secure: Decidim.config.force_ssl, expire_after: Decidim.config.expire_session_after
      end

      initializer "decidim_core.register_resources" do
        Decidim.register_resource(:user) do |resource|
          resource.model_class_name = "Decidim::User"
          resource.card = "decidim/user_profile"
          resource.searchable = true
        end
      end

      initializer "decidim_core.homepage_content_blocks" do
        Decidim::Core::ContentBlocks::RegistryManager.register_homepage_content_blocks!
      end

      initializer "decidim_core.static_page_blocks" do
        Decidim::Core::ContentBlocks::RegistryManager.register_static_page_blocks!
      end

      initializer "decidim_core.newsletter_templates" do
        Decidim::Core::ContentBlocks::RegistryManager.register_newsletter_templates!
      end

      initializer "decidim_core.add_badges" do
        Decidim::Gamification.register_badge(:followers) do |badge|
          badge.levels = [1, 15, 30, 60, 100]
          badge.reset = ->(user) { user.followers.count }
        end
      end

      # Icon library used: https://remixicon.com/
      # Just provide the respective icon name (unprefixed) and the brand color,
      # if a social-network icon is missing there, you can provide as well a SVG file as used to
      initializer "decidim_core.add_social_share_services" do
        Decidim.register_social_share_service("QR") do |service|
          service.type = :popup
          service.icon = "qr-code-line"
          service.share_uri = "/qr-code?external_url=%{url}&name=%{title}"
          service.optional_args = {
            "dialog-open": "QRCodeDialog"
          }
        end

        Decidim.register_social_share_service("Douban") do |service|
          service.icon = "douban-line"
          service.share_uri = "http://shuo.douban.com/!service/share?href=%{url}&name=%{title}&image=%{image}&sel=%{desc}"
        end

        Decidim.register_social_share_service("Email") do |service|
          service.icon = "mail-line"
          service.share_uri = "mailto:?subject=%{title}&body=%{url}"
        end

        Decidim.register_social_share_service("Facebook") do |service|
          service.icon = "facebook-circle-line"
          service.share_uri = "http://www.facebook.com/sharer/sharer.php?u=%{url}"
        end

        Decidim.register_social_share_service("Google Bookmark") do |service|
          service.icon = "google-line"
          service.share_uri = "https://www.google.com/bookmarks/mark?op=edit&output=popup&bkmk=%{url}&title=%{title}"
        end

        Decidim.register_social_share_service("Hacker News") do |service|
          service.icon = "hacker_news.svg"
          service.share_uri = "http://news.ycombinator.com/submitlink?u=%{url}&t=%{title}"
        end

        Decidim.register_social_share_service("LinkedIn") do |service|
          service.icon = "linkedin-box-fill"
          service.share_uri = "https://www.linkedin.com/shareArticle?mini=true&url=%{url}&title=%{title}&summary=%{desc}"
        end

        Decidim.register_social_share_service("Odnoklassniki") do |service|
          service.icon = "odnoklassniki.svg"
          service.share_uri = "https://connect.ok.ru/offer?url=%{url}&title=%{title}&description=%{desc}&imageUrl=%{image}"
        end

        Decidim.register_social_share_service("Pinterest") do |service|
          service.icon = "pinterest-line"
          service.share_uri = "http://www.pinterest.com/pin/create/button/?url=%{url}&media=%{image}&description=%{title}"
        end

        Decidim.register_social_share_service("Reddit") do |service|
          service.icon = "reddit-line"
          service.share_uri = "http://www.reddit.com/submit?url=%{url}&newwindow=1"
        end

        Decidim.register_social_share_service("Telegram") do |service|
          service.icon = "telegram-line"
          service.share_uri = "https://telegram.me/share/url?text=%{title}&url=%{url}"
        end

        Decidim.register_social_share_service("Twitter") do |service|
          service.icon = "twitter-line"
          service.share_uri = "https://twitter.com/intent/tweet?url=%{url}&text=%{title}"
          service.optional_params = %w(hashtags via)
        end

        Decidim.register_social_share_service("X") do |service|
          service.icon = "twitter-x-line"
          service.share_uri = "https://twitter.com/intent/tweet?url=%{url}&text=%{title}"
          service.optional_params = %w(hashtags via)
        end

        Decidim.register_social_share_service("Vkontakte") do |service|
          service.icon = "vkontakte.svg"
          service.share_uri = "http://vk.com/share.php?url=%{url}&title=%{title}&image=%{image}"
        end

        Decidim.register_social_share_service("WhatsApp") do |service|
          service.icon = "whatsapp-line"
          service.share_uri = "https://api.whatsapp.com/send?text=%{title}%%0A%{url}"
        end

        Decidim.register_social_share_service("Xing") do |service|
          service.icon = "xing-line"
          service.share_uri = "https://www.xing.com/spi/shares/new?url=%{url}"
        end
      end

      initializer "decidim_core.premailer" do
        Premailer::Adapter.use = :decidim
      end

      initializer "decidim_core.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_core.preview_mailer" do
        # Load in mailer previews for apps to use in development.
        # We need to make sure we call `Preview.all` before requiring our
        # previews, otherwise any previews the app attempts to add need to be
        # manually required.
        if Rails.env.local?
          ActionMailer::Preview.all

          Dir[root.join("spec/mailers/previews/**/*_preview.rb")].each do |file|
            require_dependency file
          end
        end
      end

      # These are moved from initializers/devise.rb because we need to run initializers folder before
      # setting these or Decidim.config variables have default values.
      initializer "decidim_core.after_initializers_folder", after: "load_config_initializers" do
        Devise.setup do |config|
          # ==> Mailer Configuration
          # Configure the e-mail address which will be shown in Devise::Mailer,
          # note that it will be overwritten if you use your own mailer class
          # with default "from" parameter.
          config.mailer_sender = Decidim.config.mailer_sender

          # A period that the user is allowed to access the website even without
          # confirming their account. For instance, if set to 2.days, the user will be
          # able to access the website for two days without confirming their account,
          # access will be blocked just in the third day. Default is 0.days, meaning
          # the user cannot access the website without confirming their account.
          config.allow_unconfirmed_access_for = Decidim.unconfirmed_access_for

          # ==> Configuration for :timeoutable
          # The time you want to timeout the user session without activity. After this
          # time the user will be asked for credentials again. Default is 30 minutes.
          config.timeout_in = Decidim.config.expire_session_after
        end
      end

      initializer "decidim_core.authorization_transfer" do
        config.to_prepare do
          Decidim::AuthorizationTransfer.register(:core) do |transfer|
            transfer.move_records(Decidim::Coauthorship, :decidim_author_id)
            transfer.move_records(Decidim::Like, :decidim_author_id)
            transfer.move_records(Decidim::Amendment, :decidim_user_id)
          end
        end
      end

      config.to_prepare do
        ActiveSupport.on_load(:action_view) do
          include Decidim::FlashHelperExtensions
        end
      end
    end
  end
end
