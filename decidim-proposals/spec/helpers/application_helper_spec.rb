# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ApplicationHelper do
      describe "#humanize_proposal_state" do
        subject { helper.humanize_proposal_state(state) }

        context "when it is accepted" do
          let(:state) { "accepted" }

          it { is_expected.to eq("Accepted") }
        end

        context "when it is rejected" do
          let(:state) { "rejected" }

          it { is_expected.to eq("Rejected") }
        end

        context "when it is nil" do
          let(:state) { nil }

          it { is_expected.to eq("Not answered") }
        end

        context "when it is withdrawn" do
          let(:state) { "withdrawn" }

          it { is_expected.to eq("Withdrawn") }
        end
      end

      describe "#render_proposal_body" do
        subject { helper.render_proposal_body(proposal) }

        before do
          allow(helper).to receive(:present).with(proposal).and_return(Decidim::Proposals::ProposalPresenter.new(proposal))
          allow(helper).to receive(:current_organization).and_return(proposal.organization)
          helper.instance_variable_set(:@proposal, proposal)
        end

        let(:body) { "<ul><li>First</li><li>Second</li><li>Third</li></ul><script>alert('OK');</script>" }
        let(:proposal_trait) { :participant_author }
        let(:proposal) { create(:proposal, proposal_trait, body: { "en" => body }) }

        it "renders a sanitized body" do
          expect(subject).to eq(
            <<~HTML.strip
              <p>• First
              <br />• Second
              <br />• Third
              </p>
            HTML
          )
        end

        context "with official proposal" do
          let(:proposal_trait) { :official }

          it "renders a sanitized body" do
            expect(subject).to eq(
              <<~HTML.sub(/\n$/, "")
                <div class="rich-text-display">
                <ul>
                <li>First</li>
                <li>Second</li>
                <li>Third</li>
                </ul>alert('OK');</div>
              HTML
            )
          end

          context "when the body includes images and iframes" do
            let(:body) do
              <<~HTML.strip
                <p><img src="/path/to/image.jpg" alt="Image"></p>
                <div class="editor-content-videoEmbed">
                  <div>
                    <iframe src="https://example.org/video/xyz" title="Video" frameborder="0" allowfullscreen="true"></iframe>
                  </div>
                </div>
              HTML
            end

            it "renders the image and iframe embed" do
              expect(subject).to eq(
                <<~HTML.strip
                  <div class="rich-text-display">
                  <p><img src="/path/to/image.jpg" alt="Image"></p>
                  <div class="editor-content-videoEmbed">
                    <div>
                      <div class="disabled-iframe"><!-- <iframe src="https://example.org/video/xyz" title="Video" frameborder="0" allowfullscreen="true" scrolling="no"></iframe> --></div>
                    </div>
                  </div>
                  </div>
                HTML
              )
            end
          end
        end
      end

      describe "#proposal_limit" do
        subject { helper.proposal_limit }

        context "when proposal limit is zero" do
          before do
            allow(helper).to receive(:component_settings).and_return(double(proposal_limit: 0))
          end

          it "returns nil" do
            expect(subject).to be_nil
          end
        end

        context "when proposal limit is greater than zero" do
          before do
            allow(helper).to receive(:component_settings).and_return(double(proposal_limit: 5))
          end

          it "returns the proposal limit" do
            expect(subject).to eq(5)
          end
        end
      end

      describe "#votes_given" do
        subject { helper.send(:votes_given) }

        let(:user) { create(:user) }
        let(:component) { create(:component, manifest_name: :proposals) }

        before do
          allow(helper).to receive(:current_user).and_return(user)
          allow(helper).to receive(:current_component).and_return(component)
        end

        context "when the user has not voted on any proposals" do
          it "returns 0" do
            expect(subject).to eq(0)
          end
        end

        context "when votes_given is already calculated" do
          it "memoizes the result" do
            allow(ProposalVote).to receive(:where).and_call_original
            expect(helper.send(:votes_given)).to eq(0)
            expect(ProposalVote).not_to receive(:where)
            expect(helper.send(:votes_given)).to eq(0)
          end
        end
      end

      describe "#filter_type_values" do
        subject { helper.filter_type_values }

        before do
          allow(helper).to receive(:t).with("decidim.proposals.application_helper.filter_type_values.all").and_return("All")
          allow(helper).to receive(:t).with("decidim.proposals.application_helper.filter_type_values.proposals").and_return("Proposals")
          allow(helper).to receive(:t).with("decidim.proposals.application_helper.filter_type_values.amendments").and_return("Amendments")
        end

        it "returns the correct filter type values" do
          expect(subject).to eq([
                                  %w(all All),
                                  %w(proposals Proposals),
                                  %w(amendments Amendments)
                                ])
        end

        it "returns an array of arrays with two elements each" do
          expect(subject).to all(be_an(Array).and(have_attributes(size: 2)))
        end

        it "includes the expected filter types" do
          filter_keys = subject.map(&:first)
          expect(filter_keys).to contain_exactly("all", "proposals", "amendments")
        end

        it "includes the translated values for each filter type" do
          translated_values = subject.map(&:last)
          expect(translated_values).to contain_exactly("All", "Proposals", "Amendments")
        end
      end
    end
  end
end
