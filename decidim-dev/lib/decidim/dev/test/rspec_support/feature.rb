# frozen_string_literal: true

require "decidim/feature_validator"
require "decidim/comments"

module Decidim
  # Dummy engine to be able to test components.
  class DummyEngine < Rails::Engine
    engine_name "dummy"

    routes do
      root to: proc { [200, {}, ["DUMMY ENGINE"]] }
      resources :dummy_resources, controller: "decidim/dummy_resources"
    end
  end

  class DummyAdminEngine < Rails::Engine
    engine_name "dummy_admin"

    routes do
      root to: proc { [200, {}, ["DUMMY ADMIN ENGINE"]] }
    end
  end

  class DummyResourceEvent < Events::BaseEvent
    include Decidim::Events::EmailEvent
    include Decidim::Events::NotificationEvent
  end

  module DummyResources
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end

    class DummyResource < ApplicationRecord
      include HasFeature
      include Resourceable
      include Reportable
      include Authorable
      include HasCategory
      include HasScope
      include Decidim::Comments::Commentable
      include Followable

      feature_manifest_name "dummy"

      def reported_content_url
        ResourceLocatorPresenter.new(self).url
      end
    end
  end

  class DummyResourcesController < ActionController::Base
    helper Decidim::Comments::CommentsHelper
    skip_authorization_check

    def show
      @commentable = DummyResources::DummyResource.find(params[:id])
      render inline: %{
        <%= csrf_meta_tags %>
        <%= display_flash_messages %>
        <div class="reveal" id="loginModal" data-reveal></div>
        <%= javascript_include_tag 'application' %>
        <%= inline_comments_for(@commentable) %>
      }
    end
  end
end

class DummySerializer
  def initialize(id)
    @id = id
  end

  def serialize
    {
      id: @id
    }
  end
end

Decidim.register_feature(:dummy) do |feature|
  feature.engine = Decidim::DummyEngine
  feature.admin_engine = Decidim::DummyAdminEngine
  feature.icon = "decidim/dummy.svg"

  feature.actions = %w(foo bar)

  feature.settings(:global) do |settings|
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :dummy_global_attribute_1, type: :boolean
    settings.attribute :dummy_global_attribute_2, type: :boolean
  end

  feature.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :dummy_step_attribute_1, type: :boolean
    settings.attribute :dummy_step_attribute_2, type: :boolean
  end

  feature.register_resource do |resource|
    resource.name = :dummy
    resource.model_class_name = "Decidim::DummyResources::DummyResource"
    resource.template = "decidim/dummy_resource/linked_dummys"
  end

  feature.exports :dummies do |exports|
    exports.collection do
      [1, 2, 3]
    end

    exports.serializer DummySerializer
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Migration.suppress_messages do
      unless ActiveRecord::Base.connection.data_source_exists?("decidim_dummy_resources")
        ActiveRecord::Migration.create_table :decidim_dummy_resources do |t|
          t.string :title
          t.text :address
          t.float :latitude
          t.float :longitude

          t.references :decidim_feature, index: true
          t.references :decidim_author, index: true
          t.references :decidim_category, index: true
          t.references :decidim_scope, index: true

          t.timestamps
        end
      end
    end
  end

  config.before(:each) do
    Decidim.find_feature_manifest(:dummy).reset_hooks!
  end
end
