# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalForm do
        it_behaves_like "a proposal form", i18n: true, admin: true
        it_behaves_like "a proposal form with meeting as author", i18n: true, admin: true

        describe "#meetings" do
          let(:organization) { create(:organization, available_locales: [:en]) }
          let(:participatory_space) { create(:participatory_process, :with_phases, organization:) }
          let(:component) { create(:proposal_component, participatory_space:) }
          let(:meeting_component) { create(:meeting_component, participatory_space:) }
          let(:other_meeting_component) { create(:meeting_component, participatory_space:) }
          let!(:meetings) { create_list(:meeting, 2, :published, component: meeting_component) }
          let!(:other_component_meetings) { create_list(:meeting, 2, :published, component: other_meeting_component) }

          let(:form) do
            described_class.new.with_context(
              current_component: component,
              current_organization: organization,
              current_participatory_space: participatory_space
            )
          end

          def sql_queries(&)
            queries = []
            callback = lambda do |_name, _started, _finished, _unique_id, payload|
              queries << payload[:sql]
            end

            ActiveSupport::Notifications.subscribed(callback, "sql.active_record", &)
            queries
          end

          it "eager loads the component and its participatory space and organization, as presenters use them through the delegated organization" do
            loaded_meetings = form.meetings.to_a

            expect(loaded_meetings).to match_array(meetings + other_component_meetings)
            loaded_meetings.each do |meeting|
              expect(meeting.association(:component).loaded?).to be(true)
              expect(meeting.component.association(:participatory_space).loaded?).to be(true)
              expect(meeting.component.participatory_space.association(:organization).loaded?).to be(true)
            end
          end

          it "does not query the database when rendering the option titles of meetings from different components" do
            loaded_meetings = form.meetings.to_a

            queries = sql_queries do
              # Cached results would hide the repeated loads, so render without the query cache.
              ActiveRecord::Base.connection.uncached do
                loaded_meetings.map { |meeting| form.present(meeting).title(html_escape: true) }
              end
            end

            expect(queries).to be_empty
          end
        end
      end
    end
  end
end
