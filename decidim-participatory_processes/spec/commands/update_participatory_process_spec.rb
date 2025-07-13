# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::UpdateParticipatoryProcess do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:my_process) { create(:participatory_process, organization:, taxonomies:) }
      let(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization:) }
      let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }
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
            weight: my_process.weight,
            slug: my_process.slug,
            meta_scope: my_process.meta_scope,
            promoted: my_process.promoted,
            description_en: my_process.description,
            description_ca: my_process.description,
            description_es: my_process.description,
            short_description_en: my_process.short_description,
            short_description_ca: my_process.short_description,
            short_description_es: my_process.short_description,
            current_organization: organization,
            errors: my_process.errors,
            participatory_process_group: my_process.participatory_process_group,
            private_space: my_process.private_space,
            taxonomies: [taxonomy.id, taxonomies.first.id]
          }.merge(attachment_params)
        }
      end
      let(:attachment_params) do
        {
          hero_image: my_process.hero_image.blob
        }
      end
      let(:context) do
        {
          current_organization: organization,
          current_user: user,
          process_id: my_process.id
        }
      end
      let(:form) do
        Admin::ParticipatoryProcessForm.from_params(params).with_context(context)
      end
      let(:command) { described_class.new(form, my_process) }

      describe "when the form is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not update the participatory process" do
          command.call
          my_process.reload

          expect(my_process.title["en"]).not_to eq("Foo title")
        end
      end

      describe "when the participatory process is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(false)
          expect(my_process).to receive(:valid?).at_least(:once).and_return(false)
          my_process.errors.add(:hero_image, "File resolution is too large")
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "adds errors to the form" do
          command.call

          expect(form.errors[:hero_image]).not_to be_empty
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "updates the taxonomizations" do
          expect(my_process.reload.taxonomies).to match_array(taxonomies)
          command.call
          expect(my_process.reload.taxonomies).to contain_exactly(taxonomy, taxonomies.first)
        end

        it "updates the participatory process" do
          expect { command.call }.to broadcast(:ok)
          my_process.reload

          expect(my_process.title["en"]).to eq("Foo title")
        end

        it "tracks the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:update, my_process, user, {})
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end

        context "with related processes" do
          let!(:another_process) { create(:participatory_process, organization:) }

          it "links related processes" do
            allow(form).to receive(:related_process_ids).and_return([another_process.id])
            command.call

            linked_processes = my_process.linked_participatory_space_resources(:participatory_process, "related_processes")
            expect(linked_processes).to contain_exactly(another_process)
          end
        end
      end
    end
  end
end
