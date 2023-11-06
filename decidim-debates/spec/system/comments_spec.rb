# frozen_string_literal: true

require "spec_helper"

describe "Comments", perform_enqueued: true, type: :system do
  let!(:component) { create(:debates_component, organization:) }
  let!(:commentable) { create(:debate, :open_ama, component:) }

  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"
end
