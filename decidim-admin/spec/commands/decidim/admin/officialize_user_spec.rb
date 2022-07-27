# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe OfficializeUser do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:current_user) { create(:user, organization:) }

    let(:form) do
      OfficializationForm.from_params(
        officialized_as: { "en" => "Major of Barcelona" },
        user_id:
      ).with_context(
        current_user:,
        current_organization: organization
      )
    end

    context "when the form is not valid" do
      let(:user_id) { "37" }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "does not officialize users" do
        subject.call

        expect { subject.call }.not_to change(Decidim::User.where(officialized_at: nil), :count)
      end
    end

    context "when the form is valid" do
      let(:user) { create(:user, organization:) }
      let(:user_id) { user.id }
      let(:log_info) do
        hash_including(
          extra: {
            officialized_user_badge: form.officialized_as,
            officialized_user_badge_previous: form.user.officialized_as,
            officialized_user_at: a_kind_of(ActiveSupport::TimeWithZone),
            officialized_user_at_previous: form.user.officialized_at
          }
        )
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the update", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("officialize", user, current_user, log_info)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.extra["version"]).to be_nil
        expect(action_log.extra)
          .to include(
            "extra" => {
              "officialized_user_badge" => { "en" => "Major of Barcelona" },
              "officialized_user_badge_previous" => nil,
              "officialized_user_at" => a_kind_of(String),
              "officialized_user_at_previous" => nil
            }
          )
      end

      it "officializes user" do
        subject.call

        expect(user.reload).to be_officialized
      end

      it "notifies the user's followers" do
        follower = create(:user, organization:)
        create(:follow, followable: user, user: follower)

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.users.user_officialized",
            event_class: Decidim::ProfileUpdatedEvent,
            resource: kind_of(Decidim::User),
            followers: [follower]
          )

        subject.call
      end
    end
  end
end
