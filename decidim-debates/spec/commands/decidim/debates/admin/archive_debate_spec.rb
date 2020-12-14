# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Admin::ArchiveDebate do
  subject { described_class.new(archive, debate, user) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "debates" }
  let(:category) { create :category, participatory_space: participatory_process }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:debate) { create :debate, component: current_component, archived_at: archived_at }
  let(:archive) { true }
  let(:archived_at) { nil }

  context "when the debate object is not valid" do
    before do
      debate.title = nil
    end

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    context "when the archive parameter is true" do
      let(:archived_at) { nil }
      let(:archive) { true }

      it "archives the debate" do
        subject.call
        expect(debate.archived_at).to be_present
      end
    end

    context "when the archive parameter is false" do
      let(:archived_at) { 1.day.ago }
      let(:archive) { false }

      it "unarchives the debate" do
        subject.call
        expect(debate.archived_at).not_to be_present
      end
    end
  end
end
