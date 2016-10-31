# frozen_string_literal: true
require "spec_helper"

describe Decidim::AvailableProcessesForUser do
  let!(:organization) { create :organization }
  let!(:external_process) { create :participatory_process }
  let!(:published_process) { create :participatory_process, organization: organization }
  let!(:unpublished_process) { create :participatory_process, :unpublished, organization: organization }

  subject { described_class.new(user, organization) }

  describe "#query" do
    context "when no organization is given" do
      let(:user) { create :user, :admin }
      subject { described_class.new(user, nil) }

      it "returns an empty relation" do
        expect(subject.query).to eq []
        expect(subject.query).to be_kind_of(ActiveRecord::Relation)
      end
    end

    context "when the user does not belong to the organization" do
      let(:user) { create :user, :admin }

      it "only returns the published processes from the given organization" do
        expect(subject.query).to eq [published_process]
      end
    end

    context "when the user is an admin" do
      let(:user) { create :user, :admin, organization: organization }

      it "returns all processes from the given organization" do
        expect(subject.query).to match_array [published_process, unpublished_process]
      end
    end

    context "when user is not set" do
      let(:user) { }

      it "only returns the published processes from the given organization" do
        expect(subject.query).to eq [published_process]
      end
    end

    context "when user is not an admin" do
      let(:user) { create :user, organization: organization }

      it "only returns the published processes from the given organization" do
        expect(subject.query).to eq [published_process]
      end
    end
  end
end
