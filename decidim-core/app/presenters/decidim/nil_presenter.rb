# frozen_string_literal: true

module Decidim
  # A default presenter for the cases when the presented object is nil.
  # For example, when there are data inconsistencies like when a Meeting which is the creator of a proposal is removed.
  # This presenter will also be useful if the presenter for the presented object can not be resolved.
  #
  # It behaves as a presenter for deleted resources.
  # Returns an empty string for most of the method calls.
  class NilPresenter < Rectify::Presenter
    def deleted?
      true
    end

    def avatar_url
      Decidim::AvatarUploader.new.default_url
    end

    def respond_to_missing?
      true
    end

    # rubocop:disable Style/MethodMissingSuper
    def method_missing(_method, *_args)
      ""
    end
    # rubocop:enable Style/MethodMissingSuper
  end
end
