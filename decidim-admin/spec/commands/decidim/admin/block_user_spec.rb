# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe BlockUser do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:current_user) { create :user, :admin, organization: }
    let(:justification) { "justification for blocking the user" }
    let(:user_block) { create :justification, :user, :current_user }

    shared_examples "blocking user or group form" do
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

        it "Creates a User Moderation" do
          expect { subject.call }.to change(Decidim::UserModeration, :count)
        end

        it "user is notified" do
          subject.call
          expect(Decidim::BlockUserJob).to have_been_enqueued.on_queue("block_user")
        end

        it "user is updated" do
          subject.call
          expect(form.user.blocked).to be(true)
          expect(form.user.extended_data["user_name"]).to eq(user_name)
          expect(form.user.name).to eq("Blocked user")
        end

        it "original username is stored in the action log entry's resource title" do
          subject.call
          log = Decidim::ActionLog.last
          expect(log.resource).to eq(form.user)
          expect(log.extra["resource"]["title"]).to eq(user_name)
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

    context "with a user" do
      let(:user_to_block) { create :user, name: user_name, organization: }
      let(:user_name) { "Testing user" }

      it_behaves_like "blocking user or group form"
    end

    context "with a user group" do
      let(:user_to_block) { create :user_group, name: user_name, organization: }
      let(:user_name) { "Testing user group" }

      it_behaves_like "blocking user or group form"
    end
  end
end
