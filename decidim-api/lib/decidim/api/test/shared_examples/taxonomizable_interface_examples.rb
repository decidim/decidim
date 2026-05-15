# frozen_string_literal: true

require "spec_helper"

shared_examples_for "taxonomizable interface" do
  let!(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }

  before do
    model.update(taxonomies: [taxonomy])
  end

  describe "taxonomies" do
    let(:query) { "{ taxonomies { id } }" }

    it "has taxonomies" do
      expect(response).to include("taxonomies" => [{ "id" => taxonomy.id.to_s }])
    end
  end
end
