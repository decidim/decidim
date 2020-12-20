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
                                    ["key_ceremony", "text-muted"],
                                    ["ready", "text-muted"],
                                    ["vote", "text-muted"],
                                    ["tally", "text-muted"],
                                    ["results", "text-muted"],
                                    ["results_published", "text-muted"]
                                  ])
          }

          context "when current_step is ready" do
            let(:current_step) { "ready" }

            it {
              expect(subject).to eq([
                                      ["create_election", "text-success"],
                                      ["key_ceremony", "text-success"],
                                      ["ready", "text-warning"],
                                      ["vote", "text-muted"],
                                      ["tally", "text-muted"],
                                      ["results", "text-muted"],
                                      ["results_published", "text-muted"]
                                    ])
            }
          end

          context "when current_step is results_published" do
            let(:current_step) { "results_published" }

            it {
              expect(subject).to eq([
                                      ["create_election", "text-success"],
                                      ["key_ceremony", "text-success"],
                                      ["ready", "text-success"],
                                      ["vote", "text-success"],
                                      ["tally", "text-success"],
                                      ["results", "text-success"],
                                      ["results_published", "text-warning"]
                                    ])
            }
          end
        end
      end
    end
  end
end
