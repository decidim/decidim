# frozen_string_literal: true

require "spec_helper"

describe "rake decidim_proposals:upgrade:set_categories", type: :task do
  context "when executing task" do
    it "does not throw an exception" do
      expect { task.execute }.not_to raise_exception
    end
  end

  context "when there are no errors" do
    let!(:component) { create(:proposal_component, :with_amendments_enabled) }

    let(:category) { create(:category, participatory_space: component.participatory_space) }
    let(:proposal) { create(:proposal, component:, category:) }
    let!(:proposal_amendment) { create_list(:proposal_amendment, 2, amendable: proposal) }

    it "sets the category" do
      expect { task.execute }.to change(Decidim::Categorization, :count).by(2)
    end
  end
end
