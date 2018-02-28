# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::UpdateParticipatoryProcess do
    describe "call" do
      let(:my_process) { create :participatory_process }
      let(:params) do
        {
          participatory_process: {
            id: my_process.id,
            title_en: "Foo title",
            title_ca: "Foo title",
            title_es: "Foo title",
            subtitle_en: my_process.subtitle,
            subtitle_ca: my_process.subtitle,
            subtitle_es: my_process.subtitle,
            slug: my_process.slug,
            hashtag: my_process.hashtag,
            meta_scope: my_process.meta_scope,
            hero_image: nil,
            banner_image: nil,
            promoted: my_process.promoted,
            description_en: my_process.description,
            description_ca: my_process.description,
            description_es: my_process.description,
            short_description_en: my_process.short_description,
            short_description_ca: my_process.short_description,
            short_description_es: my_process.short_description,
            current_organization: my_process.organization,
            scopes_enabled: my_process.scopes_enabled,
            scope: my_process.scope,
            errors: my_process.errors,
            participatory_process_group: my_process.participatory_process_group,
            show_statistics: my_process.show_statistics
          }
        }
      end
      let(:user) { create :user, :admin, :confirmed, organization: my_process.organization }
      let(:context) do
        {
          current_organization: my_process.organization,
          current_user: user,
          process_id: my_process.id
        }
      end
      let(:form) do
        Admin::ParticipatoryProcessForm.from_params(params).with_context(context)
      end
      let(:command) { described_class.new(my_process, form) }

      describe "when the form is not valid" do
        before do
          expect(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't update the participatory process" do
          command.call
          my_process.reload

          expect(my_process.title["en"]).not_to eq("Foo title")
        end
      end

      describe "when the participatory process is not valid" do
        before do
          expect(form).to receive(:invalid?).and_return(false)
          expect(my_process).to receive(:valid?).at_least(:once).and_return(false)
          my_process.errors.add(:hero_image, "Image too big")
          my_process.errors.add(:banner_image, "Image too big")
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "adds errors to the form" do
          command.call

          expect(form.errors[:hero_image]).not_to be_empty
          expect(form.errors[:banner_image]).not_to be_empty
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "updates the participatory process" do
          expect { command.call }.to broadcast(:ok)
          my_process.reload

          expect(my_process.title["en"]).to eq("Foo title")
        end

        it "tracks the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:update, my_process, user)
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end

        context "when no homepage image is set" do
          it "does not replace the homepage image" do
            command.call
            my_process.reload

            expect(my_process.hero_image).to be_present
          end
        end

        context "when no banner image is set" do
          it "does not replace the banner image" do
            command.call
            my_process.reload

            expect(my_process.banner_image).to be_present
          end
        end
      end
    end
  end
end
