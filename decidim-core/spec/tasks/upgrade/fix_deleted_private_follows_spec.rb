# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:fix_deleted_private_follows", type: :task do
  let(:task) { Rake::Task["decidim:upgrade:fix_deleted_private_follows"] }
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:second_user) { create(:user, :confirmed, organization:) }
  let(:component) { create(:dummy_component, :published, participatory_space:) }
  let!(:followable) { create(:dummy_resource, component: component, author: user) }
  let!(:follow) { create(:follow, user:, followable: participatory_space) }
  let!(:unwanted_follow) { create(:follow, user: second_user, followable: participatory_space) }
  let!(:resource_follow) { create(:follow, followable:, user:) }
  let!(:resource_unwanted_follow) { create(:follow, followable:, user: second_user) }
  let!(:participatory_space_private_user) { create(:participatory_space_private_user, user:, privatable_to: participatory_space) }
  let(:participatory_space) { create(:participatory_process, :published, organization: user.organization) }

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  context "when assembly is private and non transparent" do
    let(:participatory_space) { create(:assembly, :private, :published, :opaque, organization: user.organization) }

    it "deletes follows of non private users" do
      # we have 2 follows, one for assembly, and one for a "child" resource
      expect { task.execute }.to change(Decidim::Follow, :count).by(-2)
    end
  end

  context "when assembly is private but transparent" do
    let(:participatory_space) { create(:assembly, :private, :published, organization: user.organization) }

    it "preserves follows of non private users" do
      # we have 2 follows, one for assembly, and one for a "child" resource
      expect { task.execute }.not_to change(Decidim::Follow, :count)
    end
  end

  context "when assembly is public" do
    let(:participatory_space) { create(:assembly, :published, organization: user.organization) }

    it "preserves follows of non private users" do
      # we have 2 follows, one for assembly, and one for a "child" resource
      expect { task.execute }.not_to change(Decidim::Follow, :count)
    end
  end

  context "when process is private" do
    let(:participatory_space) { create(:participatory_process, :private, :published, organization: user.organization) }

    it "deletes follows of non private users" do
      # we have 2 follows, one for process, and one for a "child" resource
      expect { task.execute }.to change(Decidim::Follow, :count).by(-2)
    end
  end

  context "when process is public" do
    let(:participatory_space) { create(:participatory_process, :published, organization: user.organization) }

    it "preserves follows of non private users" do
      expect { task.execute }.not_to change(Decidim::Follow, :count)
    end
  end
end
