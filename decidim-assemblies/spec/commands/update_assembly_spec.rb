# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe UpdateAssembly do
        describe "call" do
          let(:my_assembly) { create :assembly }
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
                slug: my_assembly.slug,
                hashtag: my_assembly.hashtag,
                meta_scope: my_assembly.meta_scope,
                hero_image: nil,
                banner_image: nil,
                promoted: my_assembly.promoted,
                description_en: my_assembly.description,
                description_ca: my_assembly.description,
                description_es: my_assembly.description,
                short_description_en: my_assembly.short_description,
                short_description_ca: my_assembly.short_description,
                short_description_es: my_assembly.short_description,
                current_organization: my_assembly.organization,
                scopes_enabled: my_assembly.scopes_enabled,
                scope: my_assembly.scope,
                errors: my_assembly.errors,
                show_statistics: my_assembly.show_statistics
              }
            }
          end
          let(:context) do
            {
              current_organization: my_assembly.organization,
              assembly_id: my_assembly.id
            }
          end
          let(:form) do
            AssemblyForm.from_params(params).with_context(context)
          end
          let(:command) { described_class.new(my_assembly, form) }

          describe "when the form is not valid" do
            before do
              expect(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't update the assembly" do
              command.call
              my_assembly.reload

              expect(my_assembly.title["en"]).not_to eq("Foo title")
            end
          end

          describe "when the assembly is not valid" do
            before do
              expect(form).to receive(:invalid?).and_return(false)
              expect(my_assembly).to receive(:valid?).at_least(:once).and_return(false)
              my_assembly.errors.add(:hero_image, "Image too big")
              my_assembly.errors.add(:banner_image, "Image too big")
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

            context "when no homepage image is set" do
              it "does not replace the homepage image" do
                command.call
                my_assembly.reload

                expect(my_assembly.hero_image).to be_present
              end
            end

            context "when no banner image is set" do
              it "does not replace the banner image" do
                command.call
                my_assembly.reload

                expect(my_assembly.banner_image).to be_present
              end
            end
          end
        end
      end
    end
  end
end
