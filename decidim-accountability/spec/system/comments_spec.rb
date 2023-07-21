# frozen_string_literal: true

require "spec_helper"

describe "Accountability result comments", type: :system, versioning: true do
  let!(:component) { create(:component, manifest_name: :accountability, organization:) }
  let!(:commentable) { create(:result, component:) }

  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"
end
