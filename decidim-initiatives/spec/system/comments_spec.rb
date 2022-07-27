# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let(:organization) { create(:organization) }
  let!(:initiative_type) { create(:initiatives_type, :online_signature_enabled, organization:) }
  let!(:scoped_type) { create(:initiatives_type_scope, type: initiative_type) }
  let(:commentable) { create(:initiative, :published, author: user, scoped_type:, organization:) }
  let!(:participatory_space) { commentable }
  let(:component) { nil }
  let(:resource_path) { resource_locator(commentable).path }

  include_examples "comments"
end
