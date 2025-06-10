# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe MeetingPresenter, type: :helper do
    let(:meeting) { create(:meeting, component: meeting_component) }
    let(:user) { create(:user, :admin, organization:) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
    let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
    let(:proposal) { create(:proposal, component: proposal_component) }
    let(:meeting_proposals) { meeting.authored_proposals }

    let(:presented_meeting) { described_class.new(meeting) }

    describe "#proposals" do
      subject { presented_meeting.proposals }

      before do
        proposal.coauthorships.clear
        proposal.add_coauthor(meeting)
      end

      it "has objects of type Proposal" do
        expect(subject.take).to be_an_instance_of Decidim::Proposals::Proposal
      end

      it "has at least one proposal" do
        expect(subject.size.positive?).to be true
      end

      context "when the proposal module is not installed" do
        before do
          allow(Decidim).to receive(:module_installed?).and_return(false)
        end

        it "returns an empty array and does not call authored_proposals" do
          expect(meeting).not_to receive(:authored_proposals)
          expect(subject).to be_nil
        end
      end
    end

    describe "#formatted_proposals_titles" do
      subject { presented_meeting.formatted_proposals_titles }

      before do
        proposal.coauthorships.clear
        proposal.add_coauthor(meeting)
      end

      let(:meeting_proposals) { presented_meeting.proposals }

      it "contains the associated proposals titles" do
        meeting_proposals.each_with_index do |proposal, index|
          expect(subject[index]).to include "#{index + 1}) #{proposal.title}"
        end
      end
    end

    describe "#taxonomy_names" do
      let(:taxonomy1) { create(:taxonomy, :with_parent, organization:) }
      let(:taxonomy2) { create(:taxonomy, :with_parent, organization:) }
      let(:meeting) { create(:meeting, component: meeting_component, taxonomies: [taxonomy1, taxonomy2]) }

      subject { presented_meeting.taxonomy_names }

      it "returns the taxonomy names" do
        expect(subject).to contain_exactly(translated(taxonomy1.name), translated(taxonomy2.name))
      end
    end

    describe "#description" do
      let(:description1) do
        Decidim::ContentProcessor.parse("Description #description", current_organization: organization).rewrite
      end
      let(:description2) do
        Decidim::ContentProcessor.parse("Description in Spanish #description", current_organization: organization).rewrite
      end
      let(:meeting) do
        create(
          :meeting,
          component: meeting_component,
          description: {
            en: description1,
            machine_translations: {
              es: description2
            }
          }
        )
      end

      it "parses the description in machine translations" do
        expect(meeting.description["en"]).to match(/gid:/)
        expect(meeting.description["machine_translations"]["es"]).to match(/gid:/)

        presented_description = presented_meeting.description(all_locales: true)
        expect(presented_description["en"]).to eq("Description #description")
        expect(presented_description["machine_translations"]["es"]).to eq("Description in Spanish #description")
      end

      context "when sanitizes any HTML input" do
        let(:description1) { %(<a target="alert(1)" href="javascript:alert(document.location)">XSS via target in a tag</a>) }

        it "removes the html input" do
          presented_description = presented_meeting.description(all_locales: true, strip_tags: true)
          expect(presented_description["en"]).to eq("XSS via target in a tag")
        end
      end
    end

    describe "#editor_description" do
      let(:html) do
        <<~HTML
      <p>Paragraph with a user mention #{user.to_global_id} and another user mention #{user2.to_global_id}</p>
    HTML
      end

      let(:editor_html) do
        <<~HTML
      <p>Paragraph with a user mention #{html_mention(user)} and another user mention #{html_mention(user2)}</p>
    HTML
      end
      let(:meeting) { create(:meeting, component: meeting_component, description:) }
      let(:description) { { en: html, es: html } }

      include_context "with editor content containing mentions"

      it "converts the mentions to WYSIWYG editor ready elements" do
        expect(presented_meeting.editor_description(all_locales: true)).to eq("en" => editor_html, "es" => editor_html)
      end
    end
  end
end
