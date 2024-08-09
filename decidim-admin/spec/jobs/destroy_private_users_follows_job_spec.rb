# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe DestroyPrivateUsersFollowsJob do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let(:participatory_space_private_user) { create(:participatory_space_private_user, user:) }

      context "when assembly is not transparent and user follows assembly and one meeting belonging to assembly" do
        let(:normal_user) { create(:user, organization:) }
        let(:assembly) { create(:assembly, :private, :opaque, :published, organization: user.organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: normal_user, privatable_to: assembly) }
        let!(:follow) { create(:follow, followable: assembly, user: normal_user) }
        let(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: assembly) }

        it "destroys 2 follows" do
          meeting = Decidim::Meetings::Meeting.create!(title: generate_localized_title(:meeting_title, skip_injection: false),
                                                       description: generate_localized_description(:meeting_description, skip_injection: false),
                                                       component: meetings_component, author: user)
          create(:follow, followable: meeting, user: normal_user)

          expect(Decidim::Follow.where(user: normal_user).count).to eq(2)
          expect do
            described_class.perform_now(normal_user.id, "Decidim::Assembly", assembly)
          end.to change(Decidim::Follow, :count).by(-2)
        end
      end

      context "when participatory process is private" do
        let(:normal_user) { create(:user, organization:) }
        let(:participatory_process) { create(:participatory_process, :private, :published, organization: user.organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: normal_user, privatable_to: participatory_process) }

        context "and user follows process and follows meeting belonging to process" do
          let!(:follow) { create(:follow, followable: participatory_process, user: normal_user) }
          let(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }

          it "destroys 2 follows" do
            meeting = Decidim::Meetings::Meeting.create!(title: generate_localized_title(:meeting_title, skip_injection: false),
                                                         description: generate_localized_description(:meeting_description, skip_injection: false),
                                                         component: meetings_component, author: user)
            create(:follow, followable: meeting, user: normal_user)

            expect(Decidim::Follow.where(user: normal_user).count).to eq(2)
            expect do
              described_class.perform_now(normal_user.id, "Decidim::ParticipatoryProcess", participatory_process)
            end.to change(Decidim::Follow, :count).by(-2)
          end
        end
      end
    end
  end
end
