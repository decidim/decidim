# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe StepsHelper do
        describe "#steps" do
          subject { helper.steps(current_step) }

          let(:current_step) { "create_election" }

          it {
            expect(subject).to eq([
                                    ["create_election", "text-warning"],
                                    ["created", "text-muted"],
                                    ["key_ceremony", "text-muted"],
                                    ["key_ceremony_ended", "text-muted"],
                                    ["vote", "text-muted"],
                                    ["vote_ended", "text-muted"],
                                    ["tally_started", "text-muted"],
                                    ["tally_ended", "text-muted"],
                                    ["results_published", "text-muted"]
                                  ])
          }

          context "when current_step is ready to vote" do
            let(:current_step) { "key_ceremony_ended" }

            it {
              expect(subject).to eq([
                                      ["create_election", "text-success"],
                                      ["created", "text-success"],
                                      ["key_ceremony", "text-success"],
                                      ["key_ceremony_ended", "text-warning"],
                                      ["vote", "text-muted"],
                                      ["vote_ended", "text-muted"],
                                      ["tally_started", "text-muted"],
                                      ["tally_ended", "text-muted"],
                                      ["results_published", "text-muted"]
                                    ])
            }
          end

          context "when current_step is results_published" do
            let(:current_step) { "results_published" }

            it {
              expect(subject).to eq([
                                      ["create_election", "text-success"],
                                      ["created", "text-success"],
                                      ["key_ceremony", "text-success"],
                                      ["key_ceremony_ended", "text-success"],
                                      ["vote", "text-success"],
                                      ["vote_ended", "text-success"],
                                      ["tally_started", "text-success"],
                                      ["tally_ended", "text-success"],
                                      ["results_published", "text-warning"]
                                    ])
            }
          end
        end

        describe "#fix_it_button_with_icon" do
          subject { helper.fix_it_button_with_icon(link, icon_name, method) }

          let(:link) { "/path/to/fix" }
          let(:icon_name) { "pencil-line" }
          let(:method) { :get }

          it "generates the fix it link with icon" do
            expect(subject).to have_link("Fix it", href: link)
            expect(subject).to have_selector("svg.fix-icon")
          end
        end

        describe "#technical_configuration_items" do
          subject { helper.technical_configuration_items }

          let(:expected_items) do
            [
              { key: ".technical_configuration.bulletin_board_server", value: Decidim::BulletinBoard.config[:bulletin_board_server] },
              { key: ".technical_configuration.authority_name", value: Decidim::BulletinBoard.config[:authority_name] },
              { key: ".technical_configuration.scheme_name", value: Decidim::BulletinBoard.config[:scheme_name] }
            ]
          end

          it "returns the technical configuration items" do
            expect(subject).to eq(expected_items)
          end
        end
      end
    end
  end
end
