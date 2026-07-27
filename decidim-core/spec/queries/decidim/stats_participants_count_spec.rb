# frozen_string_literal: true

require "spec_helper"

require "decidim/debates/test/factories"
require "decidim/budgets/test/factories"

describe Decidim::StatsParticipantsCount do
  subject { described_class.new(participatory_space) }

  let(:participatory_process) { create(:participatory_process, :with_steps) }
  let(:participatory_space) { participatory_process }
  let(:organization) { participatory_process.organization }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:other_user) { create(:user, :confirmed, organization:) }
  let(:component) { create(:component, manifest_name: :dummy, participatory_space:, published_at: Time.current) }
  let(:dummy_resource) { create(:dummy_resource, component:, published_at: Time.current) }

  describe "#query" do
    it "returns 0 when there are no participants" do
      expect(subject.query).to eq(0)
    end

    # ── comments_query ──────────────────────────────────────────────
    describe "comments" do
      let!(:comment) do
        create(:comment, commentable: dummy_resource, author: user, participatory_space:)
      end

      it "counts comment authors" do
        expect(subject.query).to eq(1)
      end

      it "counts unique authors across multiple comments" do
        create(:comment, commentable: dummy_resource, author: other_user, participatory_space:)
        expect(subject.query).to eq(2)
      end

      it "deduplicates the same author with multiple comments" do
        create(:comment, commentable: dummy_resource, author: user, participatory_space:)
        expect(subject.query).to eq(1)
      end
    end

    # ── debates_query ───────────────────────────────────────────────
    describe "debates" do
      let!(:debate) do
        create(:debate, :participant_author, component: create(:debates_component, participatory_space:), author: user)
      end

      it "counts debate authors" do
        expect(subject.query).to eq(1)
      end

      context "with hidden debates" do
        let!(:moderation) { create(:moderation, reportable: debate, participatory_space:, hidden_at: Time.current) }

        it "excludes hidden debates" do
          expect(subject.query).to eq(0)
        end
      end

      context "with official debate (not UserBaseEntity author)" do
        let!(:official_debate) do
          create(:debate, :official, component: create(:debates_component, participatory_space:))
        end

        it "does not count official authors" do
          expect(subject.query).to eq(1)
        end
      end
    end

    # ── meetings_query + meetings_attendees_count_query ─────────────
    describe "meetings" do
      let(:meetings_component) { create(:meeting_component, participatory_space:) }

      context "with registrations" do
        let!(:meeting) { create(:meeting, :published, component: meetings_component) }
        let!(:registration) { create(:registration, meeting:, user:) }

        it "counts registered users" do
          expect(subject.query).to eq(1)
        end

        it "counts multiple registered users" do
          create(:registration, meeting:, user: other_user)
          expect(subject.query).to eq(2)
        end
      end

      context "with participant-organized meetings" do
        let!(:meeting) do
          create(:meeting, :published, :not_official, component: meetings_component, author: user)
        end

        it "counts organizer" do
          expect(subject.query).to eq(1)
        end

        it "deduplicates when user is both organizer and registrant" do
          create(:registration, meeting:, user:)
          expect(subject.query).to eq(1)
        end
      end

      context "with hidden meetings" do
        let!(:meeting) { create(:meeting, :published, :not_official, component: meetings_component, author: user) }
        let!(:registration) { create(:registration, meeting:, user: other_user) }
        let!(:moderation) { create(:moderation, reportable: meeting, participatory_space:, hidden_at: Time.current) }

        it "excludes hidden meetings from organizers and registrations" do
          expect(subject.query).to eq(0)
        end
      end

      context "with attendees_count" do
        let!(:meeting) do
          create(:meeting, :published, :closed, closing_visible: true, attendees_count: 10, component: meetings_component)
        end

        it "sums attendees_count" do
          expect(subject.query).to eq(10)
        end

        it "sums across multiple meetings" do
          create(:meeting, :published, :closed, closing_visible: true, attendees_count: 5, component: meetings_component)
          expect(subject.query).to eq(15)
        end
      end

      context "with hidden meetings for attendees_count" do
        let!(:meeting) do
          create(:meeting, :published, :closed, closing_visible: true, attendees_count: 10, component: meetings_component)
        end
        let!(:moderation) { create(:moderation, reportable: meeting, participatory_space:, hidden_at: Time.current) }

        it "excludes hidden meetings" do
          expect(subject.query).to eq(0)
        end
      end

      context "with closing_visible false" do
        let!(:meeting) do
          create(:meeting, :published, :closed, closing_visible: false, attendees_count: 10, component: meetings_component)
        end

        it "excludes meetings with closing_visible false" do
          expect(subject.query).to eq(0)
        end
      end

      context "with unpublished meetings" do
        let!(:meeting) do
          create(:meeting, :closed, closing_visible: true, attendees_count: 10, component: meetings_component)
        end
        before { meeting.update!(published_at: nil) }

        it "excludes unpublished meetings" do
          expect(subject.query).to eq(0)
        end
      end

      context "with zero attendees_count" do
        let!(:meeting) do
          create(:meeting, :published, :closed, closing_visible: true, attendees_count: 0, component: meetings_component)
        end

        it "handles zero attendees" do
          expect(subject.query).to eq(0)
        end
      end
    end

    # ── likes_query ─────────────────────────────────────────────────
    # The likes_query filters for likes whose resource is a Component.
    # Since Likes cannot be created on Components (the Like model's
    # organization method calls resource&.component, which Components
    # do not respond to), this query always returns 0 in practice.
    describe "likes" do
      it "does not count likes on non-component resources" do
        create(:like, resource: dummy_resource, author: user)
        expect(subject.query).to eq(0)
      end
    end

    # ── proposals_query ─────────────────────────────────────────────
    describe "proposals" do
      let(:proposals_component) { create(:proposal_component, participatory_space:) }

      let!(:proposal) do
        create(:proposal, component: proposals_component, users: [user])
      end

      it "counts coauthors" do
        expect(subject.query).to eq(1)
      end

      it "counts unique coauthors across multiple proposals" do
        create(:proposal, component: proposals_component, users: [other_user])
        expect(subject.query).to eq(2)
      end

      context "with hidden proposals" do
        let!(:moderation) { create(:moderation, reportable: proposal, participatory_space:, hidden_at: Time.current) }

        it "excludes hidden proposals" do
          expect(subject.query).to eq(0)
        end
      end

      context "with official proposals" do
        let!(:official_proposal) do
          create(:proposal, :official, component: proposals_component)
        end

        it "does not count official coauthors" do
          expect(subject.query).to eq(1)
        end
      end
    end

    # ── proposals_query ─────────────────────────────────────────────
    describe "proposals" do
      let(:proposals_component) { create(:proposal_component, participatory_space:) }

      let!(:proposal) do
        create(:proposal, component: proposals_component, users: [user])
      end

      it "counts coauthors" do
        expect(subject.query).to eq(1)
      end

      it "counts unique coauthors across multiple proposals" do
        create(:proposal, component: proposals_component, users: [other_user])
        expect(subject.query).to eq(2)
      end

      context "with hidden proposals" do
        let!(:moderation) { create(:moderation, reportable: proposal, participatory_space:, hidden_at: Time.current) }

        it "excludes hidden proposals" do
          expect(subject.query).to eq(0)
        end
      end

      context "with official proposals" do
        let!(:official_proposal) do
          create(:proposal, :official, component: proposals_component)
        end

        it "does not count official coauthors" do
          expect(subject.query).to eq(1)
        end
      end
    end

    # ── project_votes_query ─────────────────────────────────────────
    describe "project votes (budget orders)" do
      let(:budget) { create(:budget, component: create(:budgets_component, participatory_space:)) }
      let!(:order) { create(:order, budget:, user:) }

      it "counts users with orders" do
        expect(subject.query).to eq(1)
      end

      it "counts multiple users" do
        other_budget = create(:budget, component: create(:budgets_component, participatory_space:))
        create(:order, budget: other_budget, user: other_user)
        expect(subject.query).to eq(2)
      end
    end

    # ── survey_response_query ───────────────────────────────────────
    describe "survey responses" do
      let(:surveys_component) { create(:surveys_component, participatory_space:, published_at: Time.current) }
      let!(:survey) { create(:survey, component: surveys_component) }
      let!(:response) do
        create(:response, questionnaire: survey.questionnaire, user:)
      end

      it "counts survey respondents" do
        expect(subject.query).to eq(1)
      end

      it "counts multiple respondents" do
        create(:response, questionnaire: survey.questionnaire, user: other_user)
        expect(subject.query).to eq(2)
      end

      context "when surveys component is unpublished" do
        before { surveys_component.update!(published_at: nil) }

        it "excludes respondents from unpublished components" do
          expect(subject.query).to eq(0)
        end
      end
    end

    # ── deduplication across queries ────────────────────────────────
    describe "deduplication across queries" do
      it "counts unique participants even when the same user appears in multiple queries" do
        create(:comment, commentable: dummy_resource, author: user, participatory_space:)
        create(:like, resource: dummy_resource, author: user)

        expect(subject.query).to eq(1)
      end

      it "sums attendees_count on top of unique participant count" do
        meetings_component = create(:meeting_component, participatory_space:)
        create(:meeting, :published, :closed, closing_visible: true, attendees_count: 7, component: meetings_component)
        create(:comment, commentable: dummy_resource, author: user, participatory_space:)

        expect(subject.query).to eq(8)
      end
    end

    # ── module not installed ────────────────────────────────────────
    context "when meetings module is not installed" do
      before do
        allow(Decidim).to receive(:module_installed?).and_call_original
        allow(Decidim).to receive(:module_installed?).with(:meetings).and_return(false)
      end

      it "gracefully handles missing meetings module" do
        expect(subject.query).to eq(0)
      end
    end

    context "when comments module is not installed" do
      let!(:comment) do
        create(:comment, commentable: dummy_resource, author: user, participatory_space:)
      end

      before do
        allow(Decidim).to receive(:module_installed?).and_call_original
        allow(Decidim).to receive(:module_installed?).with(:comments).and_return(false)
      end

      it "gracefully handles missing comments module" do
        expect(subject.query).to eq(0)
      end
    end
  end
end
