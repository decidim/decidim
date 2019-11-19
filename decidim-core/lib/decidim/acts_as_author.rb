# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to being an author.
  #
  # it mainly declares abstract methods to be implemented by artifacts
  # including it in its inheritance hierarchy.
  #
  module ActsAsAuthor
    extend ActiveSupport::Concern

    included do
      # Authors of Authorables must provide its presenters.
      #
      # Return: The presenter for the current author.
      def presenter
        raise NotImlementedError, "Authors must return an instance of its Presenter via this method."
      end
    end
  end
end
