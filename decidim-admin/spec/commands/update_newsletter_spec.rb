# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateNewsletter do
    describe "call" do
      let(:user) { create(:user, organization: organization) }
      let(:organization) { create(:organization) }
      let(:newsletter) { create(:newsletter, organization: organization) }

      let(:form) do
        double(
          subject: Decidim::Faker::Localized.paragraph(3),
          body: Decidim::Faker::Localized.paragraph(3),
          valid?: validity
        )
      end

      let(:validity) { true }

      let(:command) { described_class.new(newsletter, form, user) }

      describe "when the form is not valid" do
        let(:validity) { false }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't create a newsletter" do
          expect { command.call }.not_to(change { newsletter.reload.updated_at })
        end
      end

      describe "when the newsletter can't be edited by this user" do
        let(:user) { create(:user) }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "traces the creation", versioning: true do
          expect(Decidim.traceability)
            .to receive(:update!)
            .with(newsletter, user, a_kind_of(Hash))
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "update"
        end

        it "updates the newsletter" do
          command.call
          newsletter.reload

          expect(newsletter.author).to eq(user)
          expect(newsletter.subject).to eq(form.subject.stringify_keys)
          expect(newsletter.sent?).to eq(false)
          expect(newsletter.body).to eq(form.body.stringify_keys)
        end
      end
    end
  end
end
