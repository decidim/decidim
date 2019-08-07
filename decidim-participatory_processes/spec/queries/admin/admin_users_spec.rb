# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::AdminUsers do
    subject { described_class.new(participatory_process) }

    let(:organization) { create :organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:participatory_process_admin) do
      create(:process_admin, participatory_process: participatory_process)
    end

    it "returns the organization admins and participatory process admins" do
      expect(subject.query).to match_array([admin, participatory_process_admin])
    end
  end
end
