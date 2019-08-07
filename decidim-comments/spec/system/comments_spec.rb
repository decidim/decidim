# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let!(:component) { create(:component, manifest_name: :dummy, organization: organization) }
  let!(:author) { create(:user, :confirmed, organization: organization) }
  let!(:commentable) { create(:dummy_resource, component: component, author: author) }

  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"
end
