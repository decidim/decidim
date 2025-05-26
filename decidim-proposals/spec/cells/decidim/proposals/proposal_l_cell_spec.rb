# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalLCell, type: :cell do
    controller Decidim::Proposals::ProposalsController

    subject { cell_html }

    let(:my_cell) { cell("decidim/proposals/proposal_l", proposal, context: { show_space: }) }
    let(:cell_html) { my_cell.call }
    let(:created_at) { 1.month.ago }
    let(:published_at) { Time.current }
    let(:component) { create(:proposal_component, :with_attachments_allowed) }
    let!(:proposal) { create(:proposal, component:, created_at:, published_at:) }
    let(:model) { proposal }
    let(:user) { create(:user, organization: proposal.participatory_space.organization) }
    let!(:emendation) { create(:proposal) }
    let!(:amendment) { create(:amendment, amendable: proposal, emendation:) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it_behaves_like "m-cell", :proposal

      it "renders the card" do
        expect(subject).to have_css("[id^='proposals__proposal']")
      end

      context "and is a proposal" do
        it "renders the proposal state (nil by default)" do
          expect(subject).to have_no_css("span.label")
        end
      end

      it "renders the authorships" do
        expect(subject).to have_css(".card__list-metadata [data-author]", text: proposal.authors.first.name)
      end

      it "renders the likes count" do
        expect(subject).to have_css(".card__list-metadata [data-likes-count]")
      end

      it "renders the comments count" do
        expect(subject).to have_css(".card__list-metadata [data-comments-count]")
      end

      context "and is an emendation" do
        subject { cell_html }

        let(:my_cell) { cell("decidim/proposals/proposal_l", emendation, context: { show_space: }) }
        let(:cell_html) { my_cell.call }

        it "renders amendment text" do
          expect(subject).to have_css("div.card__list-metadata div", text: "Amendment")
        end

        it "renders the emendation state (evaluating by default)" do
          expect(subject).to have_css(".warning")
          expect(subject).to have_css("span.label", text: emendation.state.capitalize)
        end
      end
    end

    describe "#cache_hash" do
      let(:my_cell) { cell("decidim/proposals/proposal_l", proposal) }

      it "generate a unique hash" do
        old_hash = my_cell.send(:cache_hash)

        expect(my_cell.send(:cache_hash)).to eq(old_hash)
      end

      context "when locale change" do
        let(:alt_locale) { :ca }

        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          allow(I18n).to receive(:locale).and_return(alt_locale)

          my_cell.remove_instance_variable(:@cache_hash)
          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when model is updated" do
        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          proposal.update!(title: { en: "New title" })

          my_cell.remove_instance_variable(:@cache_hash)
          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when new like" do
        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          create(:like, resource: proposal, author: build(:user, organization: proposal.participatory_space.organization))

          my_cell.remove_instance_variable(:@cache_hash)
          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when new vote" do
        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          create(:proposal_vote, proposal:)
          my_cell.model.reload

          my_cell.remove_instance_variable(:@cache_hash)
          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when component settings changes" do
        it "generate a different hash" do
          component_settings = component.settings
          old_hash = my_cell.send(:cache_hash)
          component.settings = { foo: "bar" }
          component.save!

          my_cell.remove_instance_variable(:@cache_hash)
          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
          component.settings = component_settings
        end
      end

      context "when followers changes" do
        let(:another_user) { create(:user, organization: proposal.participatory_space.organization) }

        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          create(:follow, followable: proposal, user: another_user)

          my_cell.remove_instance_variable(:@cache_hash)
          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when user follows proposal" do
        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          create(:follow, followable: proposal, user:)

          my_cell.remove_instance_variable(:@cache_hash)
          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when authors changes" do
        context "when new co-author" do
          it "generate a different hash" do
            old_hash = my_cell.send(:cache_hash)
            model.add_coauthor(user)

            my_cell.remove_instance_variable(:@cache_hash)
            expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
          end

          context "when author updates profile" do
            it "generate a different hash" do
              old_hash = my_cell.send(:cache_hash)
              model.authors.first.update(personal_url: "new personal url")

              my_cell.remove_instance_variable(:@cache_hash)
              expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
            end
          end
        end
      end

      context "when caching multiple proposals" do
        let!(:proposals) { create_list(:proposal, 5, component:, created_at:, published_at:) }

        let(:cached_proposals) do
          proposals.map { |proposal| cell("decidim/proposals/proposal_l", proposal).send(:cache_hash) }
        end

        it "returns different hashes" do
          expect(cached_proposals.uniq.length).to eq(5)
        end
      end

      context "when space is rendered" do
        it "generates a different hash" do
          old_hash = my_cell.send(:cache_hash)
          my_cell.context.merge!({ show_space: true })

          my_cell.remove_instance_variable(:@cache_hash)
          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when the active participatory space step change" do
        let(:step1) { create(:participatory_process_step, participatory_process:, active: step_1_active) }
        let(:step_1_active) { true }
        let(:step2) { create(:participatory_process_step, participatory_process:, active: step_2_active) }
        let(:step_2_active) { false }
        let(:step3) { create(:participatory_process_step, participatory_process:, active: step_3_active) }
        let(:step_3_active) { false }
        let(:component) do
          create(:proposal_component,
                 participatory_space: participatory_process,
                 step_settings: {
                   step1.id => { votes_enabled: false },
                   step2.id => { votes_enabled: true },
                   step3.id => { votes_enabled: false }
                 })
        end
        let(:participatory_process) { create(:participatory_process) }

        context "when the voting period starts" do
          it "generates a different hash" do
            old_hash = my_cell.send(:cache_hash)

            step1.update!(active: false)
            step2.update!(active: true)
            proposal.reload

            my_cell.remove_instance_variable(:@cache_hash)
            expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
          end
        end

        context "when the voting period ends" do
          let(:step_1_active) { false }
          let(:step_2_active) { true }

          it "generates a different hash" do
            old_hash = my_cell.send(:cache_hash)

            step2.update!(active: false)
            step3.update!(active: true)
            proposal.reload

            my_cell.remove_instance_variable(:@cache_hash)
            expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
          end
        end
      end
    end
  end
end
