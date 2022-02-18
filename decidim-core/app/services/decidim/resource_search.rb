# frozen_string_literal: true

module Decidim
  # This is the base class to be used by other search services. This helps the
  # searches to work with context attributes that are not passed from the user
  # interface.
  class ResourceSearch < Ransack::Search
    attr_reader :user, :organization, :component, :search_context

    def initialize(object, params = {}, options = {})
      @user = options[:current_user] || options[:user]
      @component = options[:component]
      @organization = options[:organization] || component&.organization
      @search_context = options[:search_context] || :participants
      configure(options)

      # The super method calls the build method in the super class, which can be
      # overridden by the individual search implementations, so call this as the
      # last thing at the initialize method. The params are passed to the
      # build method as the only argument.
      super
    end

    def configure(options)
      # This can be overridden by the search implementations in order to set
      # extra variables based on the options passed to the search class before
      # calling the build method below.
    end
  end
end
