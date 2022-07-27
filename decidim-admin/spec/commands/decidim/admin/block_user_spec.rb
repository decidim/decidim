# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe BlockUser do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:current_user) { create :user, :admin, organization: }
    let(:user_to_block) { create :user, :managed, name: "Testingname", organization: }
    let(:justification) { "justification for blocking the user" }
    let(:user_block) { create :justification, :user, :current_user }

    context "when the form is valid" do
      let(:form) do
        double(
          user: user_to_block,
          current_user:,
          justification: :justification,
          valid?: true
        )
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok, user_to_block)
      end

      it "user is notified" do
        subject.call
        expect(Decidim::BlockUserJob).to have_been_enqueued.on_queue("block_user")
      end

      it "user is updated" do
        subject.call
        expect(form.user.blocked).to be(true)
        expect(form.user.extended_data["user_name"]).to eq("Testingname")
        expect(form.user.name).to eq("Blocked user")
      end

      it "original username is stored in the action log entry's resource title" do
        subject.call
        log = Decidim::ActionLog.last
        expect(log.resource).to eq(form.user)
        expect(log.extra["resource"]["title"]).to eq("Testingname")
      end

      it "tracks the changes" do
        expect(Decidim.traceability).to receive(:perform_action!).with("block",
                                                                       user_to_block,
                                                                       current_user,
                                                                       extra: {
                                                                         reportable_type: form.user.class.name,
                                                                         current_justification: form.justification
                                                                       },
                                                                       resource: {
                                                                         title: form.user.name
                                                                       })
        subject.call
      end
    end

    context "when the form is not ok" do
      let(:form) do
        double(
          valid?: false
        )
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
