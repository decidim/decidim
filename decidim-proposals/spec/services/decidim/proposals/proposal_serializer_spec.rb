# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSerializer do
      subject do
        described_class.new(proposal)
      end

      let!(:proposal) { create(:proposal, :accepted, body:) }
      let!(:category) { create(:category, participatory_space: component.participatory_space) }
      let!(:scope) { create(:scope, organization: component.participatory_space.organization) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { proposal.component }

      let!(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
      let(:meetings) { create_list(:meeting, 2, :published, component: meetings_component) }

      let!(:proposals_component) { create(:component, manifest_name: "proposals", participatory_space: participatory_process) }
      let(:other_proposals) { create_list(:proposal, 2, component: proposals_component) }
      let(:body) { Decidim::Faker::Localized.localized { ::Faker::Lorem.sentences(number: 3).join("\n") } }

      let(:expected_answer) do
        answer = proposal.answer
        Decidim.available_locales.each_with_object({}) do |locale, result|
          result[locale.to_s] = if answer.is_a?(Hash)
                                  answer[locale.to_s] || ""
                                else
                                  ""
                                end
        end
      end

      before do
        proposal.update!(category:)
        proposal.update!(scope:)
        proposal.link_resources(meetings, "proposals_from_meeting")
        proposal.link_resources(other_proposals, "copied_from_component")
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: proposal.id)
        end

        describe "author" do
          context "when it is an official proposal" do
            let!(:proposal) { create(:proposal, :official) }

            before do
              component.participatory_space.organization.update!(name: { en: "My organization" })
              proposal.reload
            end

            it "serializes the organization name" do
              expect(serialized[:author]).to include(name: ["My organization"])
            end

            it "serializes the link to the organization" do
              expect(serialized[:author]).to include(url: [root_url])
            end
          end

          context "when it is a user" do
            let!(:proposal) { create(:proposal, :participant_author) }

            before do
              proposal.creator_author.update!(name: "John Doe")
              proposal.reload
            end

            it "serializes the user name" do
              expect(serialized[:author]).to include(name: ["John Doe"])
            end

            it "serializes the link to its profile" do
              expect(serialized[:author]).to include(url: [profile_url(proposal.creator_author.nickname)])
            end
          end

          context "when it is multiple users" do
            let!(:coauthorships) { create_list(:coauthorship, 3, coauthorable: proposal) }

            it "serializes the user names" do
              expect(serialized[:author]).to include(name: proposal.authors.map(&:name))
            end

            it "serializes the link to the profiles" do
              urls = proposal.authors.map { |author| profile_url(author.nickname) }
              expect(serialized[:author]).to include(url: urls)
            end
          end

          context "when it is a meeting" do
            let!(:proposal) { create(:proposal, :official_meeting) }

            it "serializes the title of the meeting" do
              title = proposal.authors.map { |author| translated_attribute(author.title) }
              expect(serialized[:author]).to include(name: title)
            end

            it "serializes the link to the meeting" do
              urls = proposal.authors.map { |meeting| meeting_url(meeting) }
              expect(serialized[:author]).to include(url: urls)
            end
          end

          context "when it is a user group" do
            let!(:proposal) { create(:proposal, :user_group_author) }

            before do
              proposal.coauthorships.first.user_group.update!(name: "ACME", nickname: "acme")
              proposal.reload
            end

            it "serializes the user name of the user group" do
              expect(serialized[:author]).to include(name: ["ACME"])
            end

            it "serializes the link to the profile of the user group" do
              expect(serialized[:author]).to include(url: [profile_url("acme")])
            end
          end
        end

        it "serializes the category" do
          expect(serialized[:category]).to include(id: category.id)
          expect(serialized[:category]).to include(name: category.name)
        end

        it "serializes the scope" do
          expect(serialized[:scope]).to include(id: scope.id)
          expect(serialized[:scope]).to include(name: scope.name)
        end

        it "serializes the title" do
          expect(serialized).to include(title: proposal.title)
        end

        it "serializes the body" do
          expect(serialized).to include(body: proposal.body)
        end

        it "serializes the address" do
          expect(serialized).to include(address: proposal.address)
        end

        it "serializes the latitude" do
          expect(serialized).to include(latitude: proposal.latitude)
        end

        it "serializes the longitude" do
          expect(serialized).to include(longitude: proposal.longitude)
        end

        it "serializes the amount of supports" do
          expect(serialized).to include(supports: proposal.proposal_votes_count)
        end

        it "serializes the amount of comments" do
          expect(serialized).to include(comments: proposal.comments_count)
        end

        it "serializes the date of creation" do
          expect(serialized).to include(published_at: proposal.published_at)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", proposal.id.to_s)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: proposal.component.id)
        end

        it "serializes the meetings" do
          expect(serialized[:meeting_urls].length).to eq(2)
          expect(serialized[:meeting_urls].first).to match(%r{http.*/meetings})
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: participatory_process.id)
          expect(serialized[:participatory_space][:url]).to include("http", participatory_process.slug)
        end

        it "serializes the state" do
          expect(serialized).to include(state: proposal.state)
        end

        it "serializes the reference" do
          expect(serialized).to include(reference: proposal.reference)
        end

        it "serializes the answer" do
          expect(serialized).to include(answer: expected_answer)
        end

        it "serializes the date of the answer" do
          expect(serialized).to include(answered_at: proposal.answered_at)
        end

        it "serializes withdrawn status" do
          expect(serialized).to include(withdrawn: proposal.withdrawn?)
        end

        it "serializes withdrawn date" do
          expect(serialized).to include(withdrawn_at: proposal.withdrawn_at)
        end

        it "serializes the amount of attachments" do
          expect(serialized).to include(attachments: proposal.attachments.count)
        end

        it "serializes the endorsements" do
          expect(serialized[:endorsements]).to include(total_count: proposal.endorsements.count)
          expect(serialized[:endorsements]).to include(user_endorsements: proposal.endorsements.for_listing.map { |identity| identity.normalized_author&.name })
        end

        it "serializes related proposals" do
          expect(serialized[:related_proposals].length).to eq(2)
          expect(serialized[:related_proposals].first).to match(%r{http.*/proposals})
        end

        it "serializes if proposal is_amend" do
          expect(serialized).to include(is_amend: proposal.emendation?)
        end

        it "serializes the original proposal" do
          expect(serialized[:original_proposal]).to include(title: proposal&.amendable&.title)
          expect(serialized[:original_proposal][:url]).to be_nil || include("http", proposal.id.to_s)
        end

        context "with proposal having an answer" do
          let!(:proposal) { create(:proposal, :with_answer) }

          it "serializes the answer" do
            expect(serialized).to include(answer: expected_answer)
          end
        end

        context "with rich text proposal body" do
          let(:image) { "<img src=\"logo.png\" #{alt_attribute} width=\"407\">" }
          let(:alt_attribute) { "alt=\"Logo alt attribute\"" }
          let(:body_content) do
            <<~TEXT
              <h2>This is my "heading 2" title</h2>
              <p>A "normal" description below Heading 2</p>
              <p><br></p>
              <h3>Now this is my "heading 3"</h3>
              <p><br></p>
              <ul>
              <li>This is my first option</li>
              <li>This is my second option</li>
              <li>This is my third option</li>
              </ul>
              <p><br></p>
              <p>And below an uploaded image</p>
              <p>#{image}</p>
              <p><br></p>
              <p><code>Here is code block</code></p>
            TEXT
          end
          let(:body) do
            {
              "en" => body_content,
              "machine_translation" => {
                "es" => body_content,
                "ca" => body_content
              }
            }
          end

          it "serializes the body without HTML tags" do
            expected_body = <<~TEXT.chomp
              ----------------------------
              This is my "heading 2" title
              ----------------------------

              A "normal" description below Heading 2

              Now this is my "heading 3"
              --------------------------

              * This is my first option
              * This is my second option
              * This is my third option

              And below an uploaded image

              Logo alt attribute

              Here is code block
            TEXT

            expect(serialized[:body]["en"]).to eq(expected_body)
            expect(serialized[:body]["en"]).to include("Logo alt attribute")
            expect(serialized[:body]["machine_translation"]["es"]).to eq(expected_body)
            expect(serialized[:body]["machine_translation"]["es"]).to include("Logo alt attribute")
            expect(serialized[:body]["machine_translation"]["ca"]).to eq(expected_body)
            expect(serialized[:body]["machine_translation"]["ca"]).to include("Logo alt attribute")
          end

          context "and image is uploaded without 'alt' attribute" do
            let(:alt_attribute) { "" }

            it "serializes the body without image" do
              expect(serialized[:body]["en"]).not_to include("Logo alt attribute")
              expect(serialized[:body]["machine_translation"]["es"]).not_to include("Logo alt attribute")
              expect(serialized[:body]["machine_translation"]["ca"]).not_to include("Logo alt attribute")
            end
          end
        end
      end

      def profile_url(nickname)
        Decidim::Core::Engine.routes.url_helpers.profile_url(nickname, host:)
      end

      def meeting_url(meeting)
        Decidim::EngineRouter.main_proxy(meeting.component).meeting_url(id: meeting.id, host:)
      end

      def root_url
        Decidim::Core::Engine.routes.url_helpers.root_url(host:)
      end

      def host
        proposal.organization.host
      end
    end
  end
end
