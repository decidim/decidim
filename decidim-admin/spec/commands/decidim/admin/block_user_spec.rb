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

        it "notifies the user" do
          subject.call
          expect(Decidim::BlockUserJob).to have_been_enqueued.on_queue("block_user")
        end

        it "updates the user's name" do
          subject.call
          expect(form.user.blocked).to be(true)
          expect(form.user.extended_data["user_name"]).to eq(name)
          expect(form.user.name).to eq("Blocked user")
        end

        it "updates the user's about information" do
          subject.call
          expect(form.user.blocked).to be(true)
          expect(form.user.extended_data["about"]).to eq(about)
          expect(form.user.about).to eq("")
        end

        it "updates the user's personal_url information" do
          subject.call
          expect(form.user.blocked).to be(true)
          expect(form.user.extended_data["personal_url"]).to eq(personal_url)
          expect(form.user.personal_url).to eq("")
        end

        it "removes the user's avatar" do
          expect(form.user.avatar).to be_present
          subject.call
          expect(form.user.avatar).not_to be_present
        end

        it "stores the original username in the action log resource title" do
          subject.call
          log = Decidim::ActionLog.last
          expect(log.resource).to eq(form.user)
          expect(log.extra["resource"]["title"]).to eq(name)
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
      let(:user_to_block) { create :user, name:, personal_url:, about:, organization: }
      let(:name) { "Testing user" }
      let(:about) { "About field" }
      let(:personal_url) { Faker::Internet.url }

      it_behaves_like "blocking user or group form"
    end

    context "with a user group" do
      let(:user_to_block) { create :user_group, name:, personal_url:, about:, organization: }
      let(:name) { "Testing user" }
      let(:about) { "About field" }
      let(:personal_url) { Faker::Internet.url }

      it_behaves_like "blocking user or group form"
    end
  end
end
