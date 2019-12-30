# frozen_string_literal: true

require "decidim/component_validator"
require "decidim/comments"

module Decidim
  class DummyResourceEvent < Events::BaseEvent
    include Decidim::Events::EmailEvent
    include Decidim::Events::NotificationEvent
  end

  module DummyResources
    include ActiveSupport::Configurable

    # Settings needed to compare emendations in Decidim::SimilarEmendations
    config_accessor :similarity_threshold do
      0.25
    end
    config_accessor :similarity_limit do
      10
    end

    # Dummy engine to be able to test components.
    class DummyEngine < Rails::Engine
      engine_name "dummy"
      isolate_namespace Decidim::DummyResources

      routes do
        root to: proc { [200, {}, ["DUMMY ENGINE"]] }

        resources :dummy_resources do
          get :foo, on: :member
        end
      end
    end

    class DummyAdminEngine < Rails::Engine
      engine_name "dummy_admin"

      routes do
        root to: proc { [200, {}, ["DUMMY ADMIN ENGINE"]] }
      end
    end

    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end

    class DummyResource < ApplicationRecord
      include HasComponent
      include HasReference
      include Resourceable
      include Reportable
      include Authorable
      include HasCategory
      include ScopableComponent
      include Decidim::Comments::Commentable
      include Followable
      include Traceable
      include Publicable
      include Decidim::DataPortability
      include Searchable
      include Paddable
      include Amendable
      include Decidim::NewsletterParticipant
      include Hashtaggable

      searchable_fields(
        scope_id: { scope: :id },
        participatory_space: { component: :participatory_space },
        A: [:title],
        D: [:address],
        datetime: :published_at
      )

      amendable(
        fields: [:title],
        form: "Decidim::DummyResources::DummyResourceForm"
      )

      component_manifest_name "dummy"

      def reported_content_url
        ResourceLocatorPresenter.new(self).url
      end

      def allow_resource_permissions?
        component.settings.resources_permissions_enabled
      end

      def self.user_collection(user)
        where(decidim_author_id: user.id, decidim_author_type: "Decidim::User")
      end

      def self.export_serializer
        DummySerializer
      end

      def self.newsletter_participant_ids(component)
        Decidim::DummyResources::DummyResource.where(component: component).joins(:component)
                                              .where(decidim_author_type: Decidim::UserBaseEntity.name)
                                              .where.not(author: nil)
                                              .pluck(:decidim_author_id).flatten.compact.uniq
      end
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

Decidim.register_component(:dummy) do |component|
  component.engine = Decidim::DummyResources::DummyEngine
  component.admin_engine = Decidim::DummyResources::DummyAdminEngine
  component.icon = "decidim/dummy.svg"

  component.actions = %w(foo bar)

  component.newsletter_participant_entities = ["Decidim::DummyResources::DummyResource"]

  component.settings(:global) do |settings|
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :resources_permissions_enabled, type: :boolean, default: true
    settings.attribute :dummy_global_attribute_1, type: :boolean
    settings.attribute :dummy_global_attribute_2, type: :boolean
    settings.attribute :enable_pads_creation, type: :boolean, default: false
    settings.attribute :amendments_enabled, type: :boolean, default: false
    settings.attribute :dummy_global_translatable_text, type: :text, translated: true, editor: true, required: true
  end

  component.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :dummy_step_attribute_1, type: :boolean
    settings.attribute :dummy_step_attribute_2, type: :boolean
    settings.attribute :dummy_step_translatable_text, type: :text, translated: true, editor: true, required: true
    settings.attribute :amendment_creation_enabled, type: :boolean, default: true
    settings.attribute :amendment_reaction_enabled, type: :boolean, default: true
    settings.attribute :amendment_promotion_enabled, type: :boolean, default: true
    settings.attribute :amendments_visibility, type: :string, default: "all"
  end

  component.register_resource(:dummy_resource) do |resource|
    resource.name = :dummy
    resource.model_class_name = "Decidim::DummyResources::DummyResource"
    resource.template = "decidim/dummy_resource/linked_dummys"
    resource.actions = %w(foo)
    resource.searchable = true
  end

  component.register_stat :dummies_count_high, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, _start_at, _end_at|
    components.count * 10
  end

  component.register_stat :dummies_count_medium, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, _start_at, _end_at|
    components.count * 100
  end

  component.exports :dummies do |exports|
    exports.collection do
      [1, 2, 3]
    end

    exports.serializer DummySerializer
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Migration.suppress_messages do
      unless ActiveRecord::Base.connection.data_source_exists?("decidim_dummy_resources_dummy_resources")
        ActiveRecord::Migration.create_table :decidim_dummy_resources_dummy_resources do |t|
          t.jsonb :translatable_text
          t.string :title
          t.string :body
          t.text :address
          t.float :latitude
          t.float :longitude
          t.datetime :published_at
          t.integer :coauthorships_count, null: false, default: 0

          t.references :decidim_component, index: false
          t.integer :decidim_author_id, index: false
          t.string :decidim_author_type, index: false
          t.integer :decidim_user_group_id, index: false
          t.references :decidim_category, index: false
          t.references :decidim_scope, index: false
          t.string :reference

          t.timestamps
        end
      end
    end
  end

  config.before do
    Decidim.find_component_manifest(:dummy).reset_hooks!
  end
end
