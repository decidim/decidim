# frozen_string_literal: true

module Decidim
  # This cell renders the author of a resource. It is intended to be used
  # below resource titles to indicate its authorship & such, and is intended
  # for resources that have a single author.
  class RedesignedAuthorCell < Decidim::ViewModel
    include LayoutHelper
    include CellsHelper
    include Decidim::SanitizeHelper
    include ::Devise::Controllers::Helpers
    include ::Devise::Controllers::UrlHelpers
    include Messaging::ConversationHelper
    include ERB::Util

    LAYOUTS = [:default, :compact].freeze

    property :profile_path
    property :can_be_contacted?
    property :has_tooltip?

    delegate :current_user, to: :controller, prefix: false

    def author_name
      options[:author_name_text] || model.name
    end

    def show
      render layout
    end

    def profile
      render
    end

    def flag_user
      render unless current_user == model
    end

    def perform_caching?
      true
    end

    def context_actions_options
      return unless options.has_key?(:context_actions)
      return [] if options[:context_actions].blank?

      @context_actions_options ||= options[:context_actions].map(&:to_sym)
    end

    private

    def layout
      @layout ||= LAYOUTS.include?(options[:layout]) ? options[:layout] : :default
    end

    def actions_class
      layout == :compact ? "text-gray-2 text-sm" : "flex items-center gap-1"
    end

    def show_icons?
      layout != :compact
    end

    def context_actions
      return [] unless actionable?

      actions = [].tap do |list|
        list << :date if creation_date?
        list << :comments if commentable?
        list << :endorsements if endorsable?
        list << :flag if flaggable?
        list << :withdraw if withdrawable?
      end
      return actions unless has_context_actions_options?

      actions & context_actions_options
    end

    def has_context_actions_options?
      context_actions_options.is_a?(Array)
    end

    def cache_hash
      hash = []

      hash.push(I18n.locale)
      hash.push(model.cache_key_with_version) if model.respond_to?(:cache_key_with_version)
      hash.push(from_context.cache_key_with_version) if from_context.respond_to?(:cache_key_with_version)
      hash.push(current_user.try(:id))
      hash.push(current_user.present?)
      hash.push(commentable?)
      hash.push(endorsable?)
      hash.push(actionable?)
      hash.push(withdrawable?)
      hash.push(flaggable?)
      hash.push(profile_path?)
      hash.push(layout)
      hash.push(context_actions.join)
      hash.join(Decidim.cache_key_separator)
    end

    def from_context_path
      resource_locator(from_context).path
    end

    def withdraw_path
      return decidim.withdraw_amend_path(from_context.amendment) if from_context.emendation?

      "#{from_context_path}/withdraw"
    end

    def creation_date?
      return unless from_context
      return unless show_action? && (from_context.respond_to?(:published_at) || from_context.respond_to?(:created_at))

      true
    end

    def creation_date
      date_at = from_context.try(:published_at) || from_context.try(:created_at)

      l date_at, format: :decidim_short
    end

    def commentable?
      from_context && from_context.class.include?(Decidim::Comments::Commentable)
    end

    def endorsable?
      from_context && from_context.class.include?(Decidim::Endorsable)
    end

    def actionable?
      return options[:has_actions] if options.has_key?(:has_actions)

      withdrawable? || flaggable?
    end

    def user_author?
      "Decidim::UserPresenter".include?(model.class.to_s)
    end

    def profile_path?
      return false if options[:skip_profile_link] == true

      profile_path.present?
    end

    def resource_i18n_scope
      @resource_i18n_scope ||= [
        from_context.class.name.deconstantize.underscore.gsub("/", "."),
        resource_name.pluralize,
        :show
      ].join(".")
    end

    def resource_name
      @resource_name ||= from_context.class.name.demodulize.underscore
    end
  end
end
