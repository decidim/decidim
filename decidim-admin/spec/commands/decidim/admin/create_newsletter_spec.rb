# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateNewsletter do
    describe "call" do
      let(:user) { create(:user, organization: organization) }
      let(:organization) { create(:organization) }
      let(:content_block) do
        build(:content_block, :newsletter_template, organization: organization, manifest_name: :basic_only_text)
      end
      let(:newsletter_subject) { Decidim::Faker::Localized.paragraph(sentence_count: 3) }
      let(:newsletter_body) { Decidim::Faker::Localized.paragraph(sentence_count: 3) }

      let(:form) do
        Decidim::Admin::NewsletterForm.from_params(
          subject: newsletter_subject,
          settings: newsletter_body.transform_keys { |key| "body_#{key}" }
        ).with_context(current_organization: organization)
      end

      let(:command) { described_class.new(form, content_block, user) }

      describe "when the form is not valid" do
        let(:newsletter_subject) { nil }

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

        it "creates a new newsletter" do
          expect do
            command.call
          end.to change(Decidim::Newsletter, :count).by(1)
        end

        it "creates a new content block" do
          expect do
            command.call
          end.to change(Decidim::ContentBlock, :count).by(1)
        end

        it "creates a newsletter with the right attributes" do
          command.call
          newsletter = Decidim::Newsletter.last

          expect(newsletter.author).to eq(user)
          expect(newsletter.organization).to eq(organization)
          expect(newsletter.subject.deep_stringify_keys).to eq(form.subject.deep_stringify_keys)
          expect(newsletter.sent?).to be(false)
          expect(newsletter.template).to be_present
          expect(newsletter.template.settings.body.stringify_keys).to eq(newsletter_body.stringify_keys.except("machine_translations"))
        end
      end
    end
  end
end
