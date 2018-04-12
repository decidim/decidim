# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern that adds logging capability to the given model. Including this
  # allows `Decidim::ActionLog` instances related to this class to properly
  # render.
  #
  # We encourage you to overwrite the `log_presenter_class_for` class method
  # to return your custom presenter for the given log type.
  #
  # Example:
  #
  #     class MyModel < ApplicationRecord
  #       include Decidim::Loggable
  #     end
  module Loggable
    extend ActiveSupport::Concern

    class_methods do
      # Public: Finds the presenter class for the given log type.
      #
      # log - a symbol representing the log type.
      #
      # Returns a Class.
      def log_presenter_class_for(_log)
        Decidim::Log::BasePresenter
      end
    end
  end
end
