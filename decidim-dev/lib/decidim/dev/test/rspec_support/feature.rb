# frozen_string_literal: true

require 'decidim/feature_validator'
# require 'decidim/comments/helpers/comments_helper'

module Decidim
  # Dummy engine to be able to test components.
  class DummyEngine < Rails::Engine
    engine_name "dummy"

    routes do
      root to: proc { [200, {}, ["DUMMY ENGINE"]] }
      resources :dummy_resource
    end
  end

  class DummyResource < ActiveRecord::Base
    include HasFeature
    include Resourceable
    include Authorable

    feature_manifest_name "dummy"
  end

  class DummyResourcesController < ActionController::Base
    # helper Decidim::Comments::CommentsHelper
    skip_authorization_check

    def show
      @commentable = DummyResource.find(params[:id])
      @options = params.slice(:arguable, :votable)
      @options.each { |key, val| @options[key] = val === 'true' }
      render inline: %{
        <%= javascript_include_tag 'application' %>
        <%= comments_for(@commentable, @options) %>
      }.html_safe
    end
  end
end

Decidim.register_feature(:dummy) do |feature|
  feature.engine = Decidim::DummyEngine

  feature.settings(:global) do |settings|
    settings.attribute :dummy_global_attribute_1, type: :boolean
    settings.attribute :dummy_global_attribute_2, type: :boolean
  end

  feature.settings(:step) do |settings|
    settings.attribute :dummy_step_attribute_1, type: :boolean
    settings.attribute :dummy_step_attribute_2, type: :boolean
  end

  feature.register_resource do |resource|
    resource.name = :dummy
    resource.model_class_name = "Decidim::DummyResource"
    resource.template = "decidim/dummy_resource/linked_dummys"
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    unless ActiveRecord::Base.connection.data_source_exists?("decidim_dummy_resources")
      ActiveRecord::Migration.create_table :decidim_dummy_resources do |t|
        t.string :title
        t.references :decidim_feature, index: true
        t.references :decidim_author, index: true

        t.timestamps
      end
    end
  end

  config.before(:each) do
    Decidim.find_feature_manifest(:dummy).reset_hooks!
  end
end
