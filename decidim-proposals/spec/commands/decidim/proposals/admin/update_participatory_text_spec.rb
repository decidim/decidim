# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe UpdateParticipatoryText do
        describe "call" do
          let(:current_component) do
            create(
              :proposal_component,
              participatory_space: create(:participatory_process)
            )
          end
          let(:proposals) do
            proposals = create_list(:proposal, 3, component: current_component)
            proposals.each_with_index do |proposal, idx|
              level = Decidim::Proposals::ParticipatoryTextSection::LEVELS.keys[idx]
              proposal.update(participatory_text_level: level)
            end
            proposals
          end
          let(:proposal_modifications) do
            modifs = []
            new_positions = [3, 1, 2]
            proposals.each do |proposal|
              modifs << Decidim::Proposals::Admin::ProposalForm.new(
                id: proposal.id,
                position: new_positions.shift,
                title: ::Faker::Lovecraft.fhtagn,
                body: ::Faker::Lovecraft.fhtagn(5)
              )
            end
            modifs
          end
          let(:form) do
            instance_double(
              PreviewParticipatoryTextForm,
              current_component: current_component,
              proposals: proposal_modifications
            )
          end
          let(:command) { described_class.new(form) }

          describe "when form modifies proposals" do
            context "with valid values" do
              it "persists modifications" do
                expect { command.call }.to broadcast(:ok)
                proposals.zip(proposal_modifications).each do |proposal, proposal_form|
                  proposal.reload
                  actual = {}
                  expected = {}
                  %w(position title body).each do |attr|
                    next if (attr == "body") && (proposal.participatory_text_level != Decidim::Proposals::ParticipatoryTextSection::LEVELS[:article])
                    expected[attr] = proposal_form.send attr.to_sym
                    actual[attr] = proposal.attributes[attr]
                  end
                  expect(actual).to eq(expected)
                end
              end
            end

            context "with invalid values" do
              before do
                proposal_modifications.each { |proposal_form| proposal_form.title = "" }
              end

              it "does not persist modifications and broadcasts invalid" do
                failures = {}
                proposals.each do |proposal|
                  failures[proposal.id] = ["Title can't be blank"]
                end
                expect { command.call }.to broadcast(:invalid, failures)
              end
            end
          end
        end
      end
    end
  end
end
