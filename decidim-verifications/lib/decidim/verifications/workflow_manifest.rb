# frozen_string_literal: true

module Decidim
  module Verifications
    class WorkflowManifest
      include ActiveModel::Model
      include Virtus.model

      attribute :engine, Rails::Engine
      validates :engine, presence: true

      attribute :name, String
      validates :name, presence: true
    end
  end
end
