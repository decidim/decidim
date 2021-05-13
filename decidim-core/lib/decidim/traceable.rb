# frozen_string_literal: true

require "paper_trail/frameworks/active_record"
require "active_support/concern"

module Decidim
  # A concern that adds traceabilty capability to the given model. Including this
  # allows you the keep track of changes in the model attributes and changes authorship.
  #
  # Example:
  #
  #     class MyModel < ApplicationRecord
  #       include Decidim::Traceable
  #     end
  module Traceable
    extend ActiveSupport::Concern

    included do
      has_paper_trail on: [:create, :destroy, :update]

      delegate :count, to: :versions, prefix: true

      def last_whodunnit
        versions.last.try(:whodunnit)
      end

      def last_editor
        Decidim.traceability.version_editor(versions.last)
      end
    end
  end
end
