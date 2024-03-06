# frozen_string_literal: true

require "spec_helper"

describe "Comments" do
  let!(:component) { create(:component, manifest_name: :dummy, organization:) }
  let!(:commentable) { create(:dummy_resource, component:) }

  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"
end
