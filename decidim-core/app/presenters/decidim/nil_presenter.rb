# frozen_string_literal: true

module Decidim
  # A default presenter for the cases when the presented object is nil.
  # For example, when there are data inconsistencies like when a Meeting which is the creator of a proposal is removed.
  # This presenter will also be useful if the presenter for the presented object can not be resolved.
  #
  # It behaves as a presenter for deleted resources.
  # Returns an empty string for most of the method calls.
  class NilPresenter
    def initialize(*); end

    def deleted?
      true
    end

    def avatar_url(_variant = nil)
      Decidim::AvatarUploader.new(Decidim::User.new, :avatar).default_url
    end

    def respond_to_missing?(*)
      true
    end

    def method_missing(_method, *_args)
      ""
    end
  end
end
