# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::UpdateAssembly do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:my_assembly) { create(:assembly, organization:) }
      let(:user) { create(:user, :admin, :confirmed, organization: my_assembly.organization) }

      let(:participatory_processes) do
        create_list(
          :participatory_process,
          3,
          organization: my_assembly.organization
        )
      end

      let(:hero_image) { my_assembly.hero_image }
      let!(:taxonomizations) do
        2.times.map { create(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: my_assembly) }
      end
      let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
      let(:banner_image) { my_assembly.banner_image }
      let(:params) do
        {
          assembly: {
            id: my_assembly.id,
            title_en: "Foo title",
            title_ca: "Foo title",
            title_es: "Foo title",
            subtitle_en: my_assembly.subtitle,
            subtitle_ca: my_assembly.subtitle,
            subtitle_es: my_assembly.subtitle,
            weight: my_assembly.weight,
            slug: my_assembly.slug,
            meta_scope: my_assembly.meta_scope,
            promoted: my_assembly.promoted,
            description: { "en" => "Description in en", "ca" => "Description in ca", "es" => "Description in es" },
            short_description: { "en" => "Short description in en", "ca" => "Short description in ca", "es" => "Short description in es" },
            current_organization: my_assembly.organization,
            errors: my_assembly.errors,
            participatory_processes_ids: participatory_processes.map(&:id),
            purpose_of_action: my_assembly.purpose_of_action,
            composition: my_assembly.composition,
            creation_date: my_assembly.creation_date,
            created_by: my_assembly.created_by,
            created_by_other: my_assembly.created_by_other,
            duration: my_assembly.duration,
            included_at: my_assembly.included_at,
            closing_date: my_assembly.closing_date,
            closing_date_reason: my_assembly.closing_date_reason,
            internal_organisation: my_assembly.internal_organisation,
            is_transparent: my_assembly.is_transparent,
            special_features: my_assembly.special_features,
            twitter_handler: my_assembly.twitter_handler,
            facebook_handler: my_assembly.facebook_handler,
            instagram_handler: my_assembly.instagram_handler,
            youtube_handler: my_assembly.youtube_handler,
            github_handler: my_assembly.github_handler,
            announcement: my_assembly.announcement,
            taxonomies: [taxonomy.id, taxonomizations.first.taxonomy.id]
          }.merge(attachment_params)
        }
      end
      let(:attachment_params) do
        {
          hero_image: hero_image.blob,
          banner_image: banner_image.blob
        }
      end
      let(:context) do
        {
          current_organization: my_assembly.organization,
          current_user: user,
          assembly_id: my_assembly.id
        }
      end
      let(:form) do
        Admin::AssemblyForm.from_params(params).with_context(context)
      end
      let(:command) { described_class.new(form, my_assembly) }

      describe "when the form is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not update the assembly" do
          command.call
          my_assembly.reload

          expect(my_assembly.title["en"]).not_to eq("Foo title")
        end
      end

      context "when the uploaded hero image has too large dimensions" do
        let(:attachment_params) do
          {
            banner_image: banner_image.blob,
            hero_image: ActiveStorage::Blob.create_and_upload!(
              io: File.open(Decidim::Dev.asset("5000x5000.png")),
              filename: "5000x5000.png",
              content_type: "image/png"
            )
          }
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
          expect(form.errors.messages[:hero_image]).to contain_exactly("File resolution is too large")
        end
      end

      describe "when the assembly is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(false)
          expect(my_assembly).to receive(:valid?).at_least(:once).and_return(false)
          my_assembly.errors.add(:hero_image, "File resolution is too large")
          my_assembly.errors.add(:banner_image, "File resolution is too large")
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

        it "updates the assembly" do
          expect { command.call }.to broadcast(:ok)
          my_assembly.reload

          expect(my_assembly.title["en"]).to eq("Foo title")
        end

        it "updates the taxonomizations" do
          expect(my_assembly.reload.taxonomies).to contain_exactly(taxonomizations.first.taxonomy, taxonomizations.second.taxonomy)
          command.call
          expect(my_assembly.reload.taxonomies).to contain_exactly(taxonomy, taxonomizations.first.taxonomy)
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:update, my_assembly, user, {})
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end

        it "links participatory processes" do
          command.call

          linked_participatory_processes = my_assembly.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes")
          expect(linked_participatory_processes).to match_array(participatory_processes)
        end

        context "when homepage image is not updated" do
          let(:attachment_params) do
            {
              banner_image: banner_image.blob
            }
          end

          it "does not replace the homepage image" do
            expect(my_assembly).not_to receive(:hero_image=)

            command.call
            my_assembly.reload

            expect(my_assembly.hero_image).to be_present
          end
        end

        context "when banner image is not updated" do
          let(:attachment_params) do
            {
              hero_image: hero_image.blob
            }
          end

          it "does not replace the banner image" do
            expect(my_assembly).not_to receive(:banner_image=)

            command.call
            my_assembly.reload

            expect(my_assembly.banner_image).to be_present
          end
        end

        context "when updating the parent assembly" do
          let!(:parent_assembly) { create(:assembly, organization:) }

          it "increments the parent's children_count counter correctly" do
            form.parent_id = parent_assembly.id

            command.call
            my_assembly.reload
            parent_assembly.reload

            expect(my_assembly.parent).to eq(parent_assembly)
            expect(parent_assembly.children_count).to eq(parent_assembly.children.count)
          end

          it "decrements the parent's children_count counter correctly" do
            command.call
            my_assembly.reload
            parent_assembly.reload

            expect(my_assembly.parent).to be_nil
            expect(parent_assembly.children_count).to eq(parent_assembly.children.count)
          end
        end
      end
    end
  end
end
