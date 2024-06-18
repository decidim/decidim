# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:fix_deleted_private_follows", type: :task do
  let(:task) { Rake::Task["decidim:upgrade:fix_deleted_private_follows"] }
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:second_user) { create(:user, :confirmed, organization:) }

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  context "when assembly is private and non transparent" do
    context "and assembly has one private user" do
      let(:assembly) { create(:assembly, :private, :published, :opaque, organization: user.organization) }
      let!(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: assembly) }
      let!(:participatory_space_private_user) { create(:participatory_space_private_user, user:, privatable_to: assembly) }
      let!(:follow) { create(:follow, user:, followable: assembly) }
      let!(:unwanted_follow) { create(:follow, user: second_user, followable: assembly) }

      it "deletes follows of non private users" do
        meeting = Decidim::Meetings::Meeting.create!(title: generate_localized_title(:meeting_title, skip_injection: false),
                                                     description: generate_localized_description(:meeting_description, skip_injection: false),
                                                     component: meetings_component, author: user)
        create(:follow, followable: meeting, user:)
        create(:follow, followable: meeting, user: second_user)
        # we have 2 unwanted follows, one for assembly, and one for a "child" meeting
        expect do
          task.execute
        end.to change(Decidim::Follow, :count).by(-2)
      end
    end
  end

  context "when process is private" do
    context "and process has one private user" do
      let(:participatory_process) { create(:participatory_process, :private, :published, organization: user.organization) }
      let!(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
      let!(:participatory_space_private_user) { create(:participatory_space_private_user, user:, privatable_to: participatory_process) }
      let!(:follow) { create(:follow, user:, followable: participatory_process) }
      let!(:unwanted_follow) { create(:follow, user: second_user, followable: participatory_process) }

      it "deletes follows of non private users" do
        meeting = Decidim::Meetings::Meeting.create!(title: generate_localized_title(:meeting_title, skip_injection: false),
                                                     description: generate_localized_description(:meeting_description, skip_injection: false),
                                                     component: meetings_component, author: user)
        create(:follow, followable: meeting, user:)
        create(:follow, followable: meeting, user: second_user)
        # we have 2 unwanted follows, one for process, and one for a "child" meeting
        expect do
          task.execute
        end.to change(Decidim::Follow, :count).by(-2)
      end
    end
  end
end
