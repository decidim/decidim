# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module AdminLog
      describe VersionPresenter do
        let(:action_log) { double("ActionLog", action:, resource:, extra:, version:) }
        let(:resource) { double("Version", document:) }
        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:document) { create(:collaborative_text_document, title: "This is an example title document") }
        let(:extra) do
          {
            "extra" => {
              "version_number" => "2"
            },
            "resource" => {
              "title" => "This is an example title document"
            },
            "participatory_space" => {
              "title" => {
                "en" => "Participatory Process"
              }
            }
          }
        end
        let(:version) { double("Version", changeset: {}) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:presenter) { described_class.new(action_log, nil) }

        before do
          allow(action_log).to receive(:user).and_return(user)
          allow(presenter).to receive(:user).and_return(user)
          allow(presenter).to receive(:participatory_process).and_return(participatory_process)
        end

        describe "#action_string" do
          context "when action is delete" do
            let(:action) { "delete" }

            it "returns the correct translation key" do
              expect(presenter.send(:action_string)).to eq("decidim.collaborative_texts.admin_log.version.delete")
            end
          end
        end

        describe "#changeset" do
          let(:action) { "update" }

          it "returns the expected structured changeset for version update" do
            expected_changeset = [
              {
                attribute_name: :version_number,
                label: "Version number",
                new_value: "2",
                previous_value: nil,
                type: :integer
              }
            ]
            expect(presenter.send(:changeset)).to eq(expected_changeset)
          end
        end
      end
    end
  end
end
