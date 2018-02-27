# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateNewsletter do
    describe "call" do
      let(:user) { create(:user, organization: organization) }
      let(:organization) { create(:organization) }

      let(:form) do
        double(
          subject: Decidim::Faker::Localized.paragraph(3),
          body: Decidim::Faker::Localized.paragraph(3),
          valid?: validity
        )
      end

      let(:command) { described_class.new(form, user) }

      describe "when the form is not valid" do
        let(:validity) { false }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't create a newsletter" do
          expect do
            command.call
          end.not_to change(Decidim::Newsletter, :count)
        end
      end

      describe "when the form is valid" do
        let(:validity) { true }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "traces the creation", versioning: true do
          expect(Decidim.traceability)
            .to receive(:create!)
            .with(Decidim::Newsletter, user, a_kind_of(Hash))
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "create"
        end

        it "creates a new category" do
          expect do
            command.call
          end.to change(Decidim::Newsletter, :count).by(1)
        end

        it "creates a newsletter with the right attributes" do
          command.call
          newsletter = Decidim::Newsletter.last

          expect(newsletter.author).to eq(user)
          expect(newsletter.organization).to eq(organization)
          expect(newsletter.subject).to eq(form.subject.stringify_keys)
          expect(newsletter.sent?).to eq(false)
          expect(newsletter.body).to eq(form.body.stringify_keys)
        end
      end
    end
  end
end
