# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyParticipatorySpacePrivateUser do
    subject { described_class.new(participatory_space_private_user, user) }

    let(:organization) { create(:organization) }
    # let(:privatable_to) { create :participatory_process }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:participatory_space_private_user) { create(:participatory_space_private_user, user:) }

    it "destroys the participatory space private user" do
      subject.call
      expect { participatory_space_private_user.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "broadcasts ok" do
      expect do
        subject.call
      end.to broadcast(:ok)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          :delete,
          participatory_space_private_user,
          user,
          resource: { title: user.name }
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_nil
    end

    context "when assembly is not transparent" do
      let(:normal_user) { create(:user, organization:) }
      let(:assembly) { create(:assembly, :private, :opaque, :published, organization: user.organization) }
      let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: normal_user, privatable_to: assembly) }

      context "and user follows assembly" do
        let!(:follow) { create(:follow, followable: assembly, user: normal_user) }

        it "destroys the follow" do
          expect(Decidim::Follow.where(user: normal_user).count).to eq(1)
          subject.call
          expect(Decidim::Follow.where(user: normal_user).count).to eq(0)
        end

        context "and user follows meeting belonging to assembly" do
          let(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: assembly) }

          it "destroys all follows" do
            meeting = Decidim::Meetings::Meeting.create!(title: generate_localized_title(:meeting_title, skip_injection: false),
                                                         description: generate_localized_description(:meeting_description, skip_injection: false),
                                                         component: meetings_component, author: user)
            create(:follow, followable: meeting, user: normal_user)
            expect(Decidim::Follow.where(user: normal_user).count).to eq(2)
            subject.call
            expect(Decidim::Follow.where(user: normal_user).count).to eq(0)
          end
        end
      end
    end

    context "when participatory process is private" do
      let(:normal_user) { create(:user, organization:) }
      let(:participatory_process) { create(:participatory_process, :private, :published, organization: user.organization) }
      let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: normal_user, privatable_to: participatory_process) }

      context "and user follows process" do
        let!(:follow) { create(:follow, followable: participatory_process, user: normal_user) }

        it "destroys the follow" do
          expect(Decidim::Follow.where(user: normal_user).count).to eq(1)
          expect do
            subject.call
          end.to change(Decidim::Follow, :count).by(-1)
        end

        context "and user follows meeting belonging to process" do
          let(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }

          it "destroys all follows" do
            meeting = Decidim::Meetings::Meeting.create!(title: generate_localized_title(:meeting_title, skip_injection: false),
                                                         description: generate_localized_description(:meeting_description, skip_injection: false),
                                                         component: meetings_component, author: user)
            create(:follow, followable: meeting, user: normal_user)
            expect(Decidim::Follow.where(user: normal_user).count).to eq(2)
            expect do
              subject.call
            end.to change(Decidim::Follow, :count).by(-2)
          end
        end
      end
    end
  end
end
