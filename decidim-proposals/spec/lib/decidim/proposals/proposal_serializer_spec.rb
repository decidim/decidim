# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSerializer do
      subject do
        described_class.new(proposal)
      end
      let!(:body) { { en: ::Faker::Lorem.sentence } }
      let!(:proposal) { create(:proposal, :accepted, body:) }
      let!(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization: component.organization) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { proposal.component }

      let!(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
      let(:meetings) { create_list(:meeting, 2, :published, component: meetings_component) }

      let!(:proposals_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:other_proposals) { create_list(:proposal, 2, component: proposals_component) }

      let(:serialized) { subject.serialize }
      let(:serialized_taxonomies) do
        { ids: taxonomies.pluck(:id) }.merge(taxonomies.to_h { |t| [t.id, t.name] })
      end

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
        proposal.update!(taxonomies:)
        proposal.link_resources(meetings, "proposals_from_meeting")
        proposal.link_resources(other_proposals, "copied_from_component")
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: proposal.id)
        end

        it "serializes the taxonomies" do
          expect(serialized[:taxonomies]).to eq(serialized_taxonomies)
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
            let!(:user) { create(:user, name: "John Doe", organization: component.organization) }
            let(:component) { create(:proposal_component) }
            let!(:proposal) { create(:proposal, component:, users: [user]) }

            it "serializes the user name" do
              expect(serialized[:author]).to include(name: ["John Doe"])
            end

            it "serializes the link to its profile" do
              expect(serialized[:author]).to include(url: [profile_url(proposal.creator_author.nickname)])
            end

            context "when author is deleted" do
              let!(:user) { create(:user, :deleted, organization: component.organization) }
              let!(:proposal) { create(:proposal, component:, users: [user]) }

              it "serializes the user id" do
                expect(serialized[:author]).to include(id: [user.id])
              end

              it "serializes the user name" do
                expect(serialized[:author]).to include(name: [""])
              end

              it "serializes the link to its profile" do
                expect(serialized[:author]).to include(url: [""])
              end
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

        it "serializes the amount of votes" do
          expect(serialized).to include(votes: proposal.proposal_votes_count)
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

        it "serializes the state at which the proposal was published at" do
          expect(serialized).to include(state_published_at: proposal.state_published_at)
        end

        it "serializes the how many co-authorships exist" do
          expect(serialized).to include(coauthorships_count: proposal.coauthorships_count)
        end

        it "serializes the number of followers of the proposal" do
          expect(serialized).to include(follows_count: proposal.follows_count)
        end

        it "serializes the endorsements" do
          expect(serialized[:endorsements]).to include(total_count: proposal.endorsements.count)
          expect(serialized[:endorsements]).to include(user_endorsements: proposal.endorsements.for_listing.map { |identity| identity.author&.name })
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

        it "serialize the created at date" do
          expect(serialized).to include(created_at: proposal.created_at)
        end

        it "serialize the updated at date" do
          expect(serialized).to include(updated_at: proposal.updated_at)
        end

        it "serializes whether the proposal was created in a meeting" do
          expect(serialized).to include(created_in_meeting: proposal.created_in_meeting)
        end

        it "serializes the cost of the proposal" do
          expect(serialized).to include(cost: proposal.cost)
        end

        it "serializes the execution period of the proposal" do
          expect(serialized).to include(execution_period: proposal.execution_period)
        end

        # This is an internal field for admins which should not be published
        context "when proposal notes count are hidden" do
          it "does not publish them" do
            expect(serialized).not_to include(proposal_notes_count: proposal.proposal_notes_count)
          end
        end

        # This is an internal field for admins which should not be published
        context "when evaluation assignments are hidden" do
          it "does not publish them" do
            expect(serialized).not_to include(evaluation_assignments_count: proposal.evaluation_assignments_count)
          end
        end

        context "when proposals with costs that are not published" do
          let!(:proposal) { create(:proposal, :with_answer) }
          let(:cost) { proposal.cost }
          let(:cost_report) { proposal.cost_report }
          let(:execution_period) { proposal.execution_period }
          let(:answer) { proposal.answer }

          before do
            proposal.update!(cost: nil, cost_report: nil, execution_period: nil, answer: nil, state_published_at: nil)
          end

          it "includes costs with a proposal not published" do
            expect(serialized).to include(
              cost: nil,
              cost_report: nil,
              execution_period: nil,
              answer: expected_answer,
              state_published_at: nil
            )
          end
        end

        context "with proposal having an answer" do
          let!(:proposal) { create(:proposal, :with_answer) }

          it "serializes the answer" do
            expect(serialized).to include(answer: expected_answer)
          end
        end

        context "when the proposal is answered but not published" do
          before do
            proposal.update!(answered_at:, state_published_at: nil)
          end

          let(:answered_at) { Time.current }

          it "includes the answered_at timestamp and leaves state_published_at nil" do
            expect(serialized).to include(
              answered_at:,
              state_published_at: nil
            )
          end
        end

        context "when the proposal is answered and published" do
          before do
            proposal.update!(answered_at:, state_published_at:)
          end

          let(:answered_at) { Time.current }
          let(:state_published_at) { answered_at + 1.day }

          it "includes both answered_at and state_published_at timestamps" do
            expect(serialized).to include(
              answered_at:,
              state_published_at:
            )
          end
        end

        context "when the votes are hidden" do
          let!(:component) { create(:proposal_component, :with_votes_hidden) }
          let!(:proposal) { create(:proposal, component:) }

          it "does not include total count of votes" do
            expect(serialized).to include(votes: nil)
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
        Decidim::Core::Engine.routes.url_helpers.profile_url(nickname, host:, port: Capybara.server_port)
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
