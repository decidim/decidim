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
  let(:private_process) { create(:participatory_process, :private, organization:) }
  let(:private_assembly) { create(:assembly, :private, organization:) }

  before do
    # Note that it is possible to add private users also to public processes
    # and assemblies, there is no programming logic forbidding that to happen.
    [process, assembly, private_process, private_assembly].each do |space|
      10.times { create(:participatory_space_private_user, user: build(:user, :confirmed, organization:), privatable_to: space) } # rubocop:disable RSpec/FactoryBot/CreateList
    end

    # Add the user to both private spaces
    create(:participatory_space_private_user, user:, privatable_to: private_process)
    create(:participatory_space_private_user, user:, privatable_to: private_assembly)
  end

  describe "#query" do
    subject { query.query }

    let(:component) { create(:component, manifest_name: "dummy", participatory_space: process) }
    let(:comment) { create(:comment, author: user, commentable: build(:dummy_resource, component:)) }
    let!(:log) { create(:action_log, action: "create", visibility: "public-only", resource: comment, participatory_space: process, user:) }

    let(:private_component) { create(:component, manifest_name: "dummy", participatory_space: private_process) }
    let(:private_comment) { create(:comment, author: user, commentable: build(:dummy_resource, component: private_component)) }
    let!(:private_log) { create(:action_log, action: "create", visibility: "public-only", resource: private_comment, participatory_space: private_process, user:) }

    it "does not return duplicates" do
      expect(subject.count).to eq(1)
    end

    context "when the current user has access to the private space" do
      before do
        create(:participatory_space_private_user, user: current_user, privatable_to: private_process)
      end

      it "returns also the private comment without duplicates" do
        expect(subject.count).to eq(2)
      end
    end
  end
end
