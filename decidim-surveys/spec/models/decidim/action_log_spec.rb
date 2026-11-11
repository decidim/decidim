# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionLog do
  describe ".lazy_relation" do
    let(:organization) { create(:organization) }
    let(:component) { create(:component, :published, manifest_name: "surveys", organization:) }
    let(:resource_class) { Decidim::Surveys::Survey }
    let!(:resources) { create_list(:survey, 2, :published, component:) }

    include_examples "action log lazy relation for non commentable resources"
  end
end
