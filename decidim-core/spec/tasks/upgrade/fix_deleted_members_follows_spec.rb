# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:fix_deleted_members_follows", type: :task do
  let(:task) { Rake::Task["decidim:upgrade:fix_deleted_members_follows"] }
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:second_user) { create(:user, :confirmed, organization:) }
  let(:component) { create(:dummy_component, :published, participatory_space:) }
  let!(:followable) { create(:dummy_resource, component:, author: user) }
  let!(:follow) { create(:follow, user:, followable: participatory_space) }
  let!(:unwanted_follow) { create(:follow, user: second_user, followable: participatory_space) }
  let!(:resource_follow) { create(:follow, followable:, user:) }
  let!(:resource_unwanted_follow) { create(:follow, followable:, user: second_user) }
  let!(:member) { create(:member, user:, participatory_space:) }
  let(:participatory_space) { create(:participatory_process, :published, organization: user.organization) }

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  context "when assembly is restricted" do
    let(:participatory_space) { create(:assembly, :published, :restricted, organization: user.organization) }

    it "deletes follows of non members" do
      # we have 2 follows, one for assembly, and one for a "child" resource
      expect { task.execute }.to change(Decidim::Follow, :count).by(-2)
    end
  end

  context "when assembly is transparent" do
    let(:participatory_space) { create(:assembly, :published, :transparent, organization: user.organization) }

    it "preserves follows of non members" do
      # we have 2 follows, one for assembly, and one for a "child" resource
      expect { task.execute }.not_to change(Decidim::Follow, :count)
    end
  end

  context "when assembly is open" do
    let(:participatory_space) { create(:assembly, :published, :open, organization: user.organization) }

    it "preserves follows of non members" do
      # we have 2 follows, one for assembly, and one for a "child" resource
      expect { task.execute }.not_to change(Decidim::Follow, :count)
    end
  end

  context "when process is restricted" do
    let(:participatory_space) { create(:participatory_process, :published, :restricted, organization: user.organization) }

    it "deletes follows of non members" do
      # we have 2 follows, one for process, and one for a "child" resource
      expect { task.execute }.to change(Decidim::Follow, :count).by(-2)
    end
  end

  context "when process is open" do
    let(:participatory_space) { create(:participatory_process, :published, :open, organization: user.organization) }

    it "preserves follows of non members" do
      expect { task.execute }.not_to change(Decidim::Follow, :count)
    end
  end
end
