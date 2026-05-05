# frozen_string_literal: true

require "spec_helper"

describe Decidim::PublicActivities do
  let(:query) { described_class.new(organization, options) }
  let(:options) { { user:, current_user: } }

  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, :confirmed, organization:) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:process) { create(:participatory_process, organization:) }
  let(:assembly) { create(:assembly, organization:) }
  let(:restricted_process) { create(:participatory_process, :restricted, organization:) }
  let(:restricted_assembly) { create(:assembly, :restricted, organization:) }

  before do
    # Note that it is possible to add members also to public processes
    # and assemblies, there is no programming logic forbidding that to happen.
    [process, assembly, restricted_process, restricted_assembly].each do |space|
      10.times { create(:member, user: build(:user, :confirmed, organization:), participatory_space: space) }
    end

    # Add the user to both restricted spaces
    create(:member, user:, participatory_space: restricted_process)
    create(:member, user:, participatory_space: restricted_assembly)
  end

  describe "#query" do
    subject { query.query }

    let(:component) { create(:component, manifest_name: "dummy", participatory_space: process) }
    let(:resource) { create(:comment, author: user, commentable: build(:dummy_resource, component:)) }
    let!(:log) { create(:action_log, action: "create", visibility: "public-only", resource:, participatory_space: process, user:) }

    let(:restricted_component) { create(:component, manifest_name: "dummy", participatory_space: restricted_process) }
    let(:restricted_resource) { create(:comment, author: user, commentable: build(:dummy_resource, component: restricted_component)) }
    let!(:restricted_log) { create(:action_log, action: "create", visibility: "public-only", resource: restricted_resource, participatory_space: restricted_process, user:) }

    it "does not return duplicates" do
      expect(subject.count).to eq(1)
    end

    context "when the current user is a member of the restricted space" do
      before do
        create(:member, user: current_user, participatory_space: restricted_process)
      end

      it "returns also the restricted comment without duplicates" do
        expect(subject.count).to eq(2)
      end
    end

    context "with follows" do
      let(:resource) { create(:dummy_resource, component:) }
      let(:restricted_resource) { create(:dummy_resource, component: restricted_component) }

      let(:options) { { user:, current_user:, follows: Decidim::Follow.where(user:) } }
      let!(:follows) { [resource, restricted_resource].map { |f| create(:follow, followable: f, user:) } }

      it "returns the correct logs" do
        expect(subject.count).to eq(1)
      end
    end
  end
end
