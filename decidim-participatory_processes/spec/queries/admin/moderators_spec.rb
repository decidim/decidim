# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::Moderators do
    subject { described_class.new(participatory_process) }

    let(:organization) { create :organization }
    let(:participatory_process) { create :participatory_process, organization: }
    let!(:admin) { create(:user, :admin, :confirmed, organization:) }
    let!(:participatory_process_admin) do
      create(:process_admin, participatory_process:)
    end
    let!(:participatory_process_moderator) do
      create(:process_moderator, participatory_process:)
    end
    let!(:participatory_process_collaborator) do
      create(:process_collaborator, participatory_process:)
    end

    it "returns the organization admins and participatory process admins" do
      expect(subject.query).to match_array([admin, participatory_process_admin, participatory_process_moderator])
    end
  end
end
