# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages comments", type: :feature do
  let(:manifest_name) { "dummy" }
  let!(:dummy) { create :dummy_resource, feature: current_feature }
  let!(:resources) { create_list(:dummy_resource, 3, feature: current_feature) }
  let!(:reportables) do
    resources.map do |resource|
      create(:comment, commentable: resource)
    end
  end

  include_context "feature process admin"

  it_behaves_like "manage moderations"
end
