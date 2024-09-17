# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe HideMenuComponent do
    subject { described_class.new(component, user) }

    let!(:user) { create(:user, :admin, :confirmed, organization: participatory_process.organization) }
    let!(:participatory_process) { create(:participatory_process, :with_steps) }
    let!(:component) { create(:component, :unpublished, participatory_space: participatory_process) }

    it "updates the visibility of the component" do
      expect { subject.call }.to change(component, :visible).from(true).to(false)
    end
  end
end
