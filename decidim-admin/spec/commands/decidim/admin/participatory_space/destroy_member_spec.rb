# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::ParticipatorySpace
  describe DestroyMember do
    subject { described_class.new(member, user) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:member) { create(:member, user:) }

    it "destroys the member" do
      subject.call
      expect { member.reload }.to raise_error(ActiveRecord::RecordNotFound)
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
          member,
          user,
          resource: { title: user.name }
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_nil
    end

    context "when assembly is restricted and user follows assembly" do
      let(:normal_user) { create(:user, organization:) }
      let(:assembly) { create(:assembly, :restricted, :published, organization: user.organization) }
      let!(:member) { create(:member, user: normal_user, participatory_space: assembly) }
      let!(:follow) { create(:follow, followable: assembly, user: normal_user) }

      context "and assembly is transparent" do
        it "does not enqueue a job" do
          assembly.update(access_mode: :transparent)
          expect(Decidim::Follow.where(user: normal_user).count).to eq(1)
          expect { subject.call }.not_to have_enqueued_job(DestroyMembersFollowsJob)
        end
      end

      context "when assembly is not transparent" do
        it "enqueues a job" do
          assembly.update(access_mode: :restricted)
          expect(Decidim::Follow.where(user: normal_user).count).to eq(1)
          expect { subject.call }.to have_enqueued_job(DestroyMembersFollowsJob)
        end
      end
    end

    context "when participatory process is restricted" do
      let(:normal_user) { create(:user, organization:) }
      let(:participatory_process) { create(:participatory_process, :restricted, :published, organization: user.organization) }
      let!(:member) { create(:member, user: normal_user, participatory_space: participatory_process) }

      context "and user follows process" do
        let!(:follow) { create(:follow, followable: participatory_process, user: normal_user) }

        it "enqueues a job" do
          expect(Decidim::Follow.where(user: normal_user).count).to eq(1)
          expect { subject.call }.to have_enqueued_job(DestroyMembersFollowsJob)
        end
      end
    end
  end
end
