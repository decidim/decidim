# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalMCell, type: :cell do
    controller Decidim::Proposals::ProposalsController

    subject { cell_html }

    let(:my_cell) { cell("decidim/proposals/proposal_m", proposal, context: { show_space: show_space }) }
    let(:cell_html) { my_cell.call }
    let(:created_at) { 1.month.ago }
    let(:published_at) { Time.current }
    let(:component) { create(:proposal_component, :with_attachments_allowed) }
    let!(:proposal) { create(:proposal, component: component, created_at: created_at, published_at: published_at) }
    let(:model) { proposal }
    let(:user) { create :user, organization: proposal.participatory_space.organization }
    let!(:emendation) { create(:proposal) }
    let!(:amendment) { create :amendment, amendable: proposal, emendation: emendation }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--proposal")
      end

      it "renders the published_at date" do
        published_date = I18n.l(published_at.to_date, format: :decidim_short)
        creation_date = I18n.l(created_at.to_date, format: :decidim_short)

        expect(subject).to have_css(".creation_date_status", text: published_date)
        expect(subject).not_to have_css(".creation_date_status", text: creation_date)
      end

      context "and is a proposal" do
        it "renders the proposal state (nil by default)" do
          expect(subject).to have_css(".muted")
          expect(subject).not_to have_css(".card__text--status")
        end
      end

      context "and is an emendation" do
        subject { cell_html }

        let(:my_cell) { cell("decidim/proposals/proposal_m", emendation, context: { show_space: show_space }) }
        let(:cell_html) { my_cell.call }

        it "renders the emendation state (evaluating by default)" do
          expect(subject).to have_css(".warning")
          expect(subject).to have_css(".card__text--status", text: emendation.state.capitalize)
        end
      end

      context "when it is a proposal preview" do
        subject { cell_html }

        let(:my_cell) { cell("decidim/proposals/proposal_m", model, preview: true) }
        let(:cell_html) { my_cell.call }

        it "renders the card with no status info" do
          expect(subject).to have_css(".card__header")
          expect(subject).to have_css(".card__text")
          expect(subject).to have_no_css(".card-data__item")
        end
      end

      context "and has an image attachment" do
        let!(:attachment_1_pdf) { create(:attachment, :with_pdf, attached_to: proposal) }
        let!(:attachment_2_img) { create(:attachment, :with_image, attached_to: proposal) }
        let!(:attachment_3_pdf) { create(:attachment, :with_pdf, attached_to: proposal) }

        it "renders the first image in the card whatever the order between attachments" do
          expect(subject).to have_css(".card__image")
          expect(subject.find(".card__image")[:src]).to eq(attachment_2_img.reload.thumbnail_url)
        end
      end
    end

    describe "#cache_hash" do
      let(:my_cell) { cell("decidim/proposals/proposal_m", proposal) }

      it "generate a unique hash" do
        old_hash = my_cell.send(:cache_hash)

        expect(my_cell.send(:cache_hash)).to eq(old_hash)
      end

      context "when locale change" do
        let(:alt_locale) { :ca }

        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          allow(I18n).to receive(:locale).and_return(alt_locale)

          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when model is updated" do
        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          proposal.update!(title: { en: "New title" })

          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when new endorsement" do
        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          create(:endorsement, resource: proposal, author: build(:user, organization: proposal.participatory_space.organization))

          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when new vote" do
        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          create(:proposal_vote, proposal: proposal)
          my_cell.model.reload

          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when component settings changes" do
        it "generate a different hash" do
          component_settings = component.settings
          old_hash = my_cell.send(:cache_hash)
          component.settings = { foo: "bar" }
          component.save!

          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)

          component.settings = component_settings
        end
      end

      context "when model has preview" do
        let(:my_cell) { cell("decidim/proposals/proposal_m", model, preview: true) }

        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          create(:attachment, :with_image, attached_to: proposal)
          my_cell.model.reload

          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when no current user" do
        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          allow(controller).to receive(:current_user).and_return(nil)

          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when followers changes" do
        let(:another_user) { create :user, organization: proposal.participatory_space.organization }

        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          create(:follow, followable: proposal, user: another_user)

          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when user follows proposal" do
        it "generate a different hash" do
          old_hash = my_cell.send(:cache_hash)
          create(:follow, followable: proposal, user: user)

          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when authors changes" do
        context "when new co-author" do
          it "generate a different hash" do
            old_hash = my_cell.send(:cache_hash)
            model.add_coauthor(user)

            expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
          end

          context "when author updates profile" do
            it "generate a different hash" do
              old_hash = my_cell.send(:cache_hash)
              model.authors.first.update(personal_url: "new personal url")

              expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
            end
          end
        end
      end

      context "when caching multiple proposals" do
        let!(:proposals) { create_list(:proposal, 5, component: component, created_at: created_at, published_at: published_at) }

        let(:cached_proposals) do
          proposals.map { |proposal| cell("decidim/proposals/proposal_m", proposal).send(:cache_hash) }
        end

        it "returns different hashes" do
          expect(cached_proposals.uniq.length).to eq(5)
        end
      end

      context "when space is rendered" do
        it "generates a different hash" do
          old_hash = my_cell.send(:cache_hash)
          my_cell.context.merge!({ show_space: true })

          expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
        end
      end

      context "when the active participatory space step change" do
        let(:step1) { create(:participatory_process_step, participatory_process: participatory_process, active: step_1_active) }
        let(:step_1_active) { true }
        let(:step2) { create(:participatory_process_step, participatory_process: participatory_process, active: step_2_active) }
        let(:step_2_active) { false }
        let(:step3) { create(:participatory_process_step, participatory_process: participatory_process, active: step_3_active) }
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

            expect(my_cell.send(:cache_hash)).not_to eq(old_hash)
          end
        end
      end
    end
  end
end
