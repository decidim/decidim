# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe UpdateVoting do
        let(:voting) { create :voting }
        let(:params) do
          {
            voting: {
              id: voting.id,
              title_en: "Foo title",
              title_ca: "Foo title",
              title_es: "Foo title",
              description_en: voting.description["en"],
              description_ca: voting.description["ca"],
              description_es: voting.description["es"],
              slug: voting.slug,
              decidim_scope_id: voting.scope.id,
              start_time: voting.start_time,
              end_time: voting.end_time,
              promoted: voting.promoted,
              voting_type: voting.voting_type,
              census_contact_information: voting.census_contact_information
            }.merge(attachment_params)
          }
        end
        let(:attachment_params) do
          {
            banner_image: voting.banner_image.blob,
            introductory_image: voting.introductory_image.blob
          }
        end
        let(:context) do
          {
            current_organization: voting.organization,
            voting_id: voting.id
          }
        end
        let(:form) { VotingForm.from_params(params).with_context(context) }
        let(:command) { described_class.new(voting, form) }

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the voting" do
            command.call
            voting.reload

            expect(voting.title["en"]).not_to eq("Foo title")
          end
        end

        describe "when the voting is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(false)
            expect(voting).to receive(:valid?).at_least(:once).and_return(false)
            voting.errors.add(:banner_image, "File resolution is too large")
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "adds errors to the form" do
            command.call

            expect(form.errors[:banner_image]).not_to be_empty
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the voting" do
            expect { command.call }.to broadcast(:ok)
            voting.reload

            expect(voting.title["en"]).to eq("Foo title")
          end

          context "when banner image is not updated" do
            let(:attachment_params) do
              {
                introductory_image: voting.introductory_image.blob
              }
            end

            it "does not replace the banner image" do
              expect(voting).not_to receive(:banner_image=)

              command.call
              voting.reload

              expect(voting.banner_image).to be_present
            end
          end

          context "when introductory image is not updated" do
            let(:attachment_params) do
              {
                banner_image: voting.banner_image.blob
              }
            end

            it "does not replace the introductory image" do
              expect(voting).not_to receive(:introductory_image=)

              command.call
              voting.reload

              expect(voting.introductory_image).to be_present
            end
          end
        end
      end
    end
  end
end
