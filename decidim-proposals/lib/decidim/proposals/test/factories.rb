# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"
require "decidim/meetings/test/factories"

def generate_state_title(token, skip_injection: false)
  value = I18n.t(token, scope: "decidim.proposals.answers")
  Decidim::Faker::Localized.localized do
    if skip_injection
      value
    else
      "<script>alert(\"proposal_state_title\");</script> #{value}"
    end
  end
end

FactoryBot.define do
  factory :proposal_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { generate_component_name(participatory_space.organization.available_locales, :proposals) }
    manifest_name { :proposals }
    participatory_space { create(:participatory_process, :with_steps, organization:, skip_injection:) }

    after :create do |proposal_component|
      Decidim::Proposals.create_default_states!(proposal_component, nil, with_traceability: false)
    end

    trait :with_likes_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { likes_enabled: true }
        }
      end
    end

    trait :with_likes_disabled do
      step_settings do
        {
          participatory_space.active_step.id => { likes_enabled: false }
        }
      end
    end

    trait :with_votes_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { votes_enabled: true }
        }
      end
    end

    trait :with_votes_disabled do
      step_settings do
        {
          participatory_space.active_step.id => { votes_enabled: false }
        }
      end
    end

    trait :with_votes_hidden do
      step_settings do
        {
          participatory_space.active_step.id => { votes_hidden: true }
        }
      end
    end

    trait :with_vote_limit do
      transient do
        vote_limit { 10 }
      end

      settings do
        {
          vote_limit:
        }
      end
    end

    trait :with_proposal_limit do
      transient do
        proposal_limit { 1 }
      end

      settings do
        {
          proposal_limit:
        }
      end
    end

    trait :with_proposal_length do
      transient do
        proposal_length { 500 }
      end

      settings do
        {
          proposal_length:
        }
      end
    end

    trait :with_likes_blocked do
      step_settings do
        {
          participatory_space.active_step.id => {
            likes_enabled: true,
            likes_blocked: true
          }
        }
      end
    end

    trait :with_votes_blocked do
      step_settings do
        {
          participatory_space.active_step.id => {
            votes_enabled: true,
            votes_blocked: true
          }
        }
      end
    end

    trait :with_creation_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { creation_enabled: true }
        }
      end
    end

    trait :with_geocoding_enabled do
      settings do
        {
          geocoding_enabled: true
        }
      end
    end

    trait :with_attachments_allowed do
      settings do
        {
          attachments_allowed: true
        }
      end
    end

    trait :with_threshold_per_proposal do
      transient do
        threshold_per_proposal { 1 }
      end

      settings do
        {
          threshold_per_proposal:
        }
      end
    end

    trait :with_can_accumulate_votes_beyond_threshold do
      settings do
        {
          can_accumulate_votes_beyond_threshold: true
        }
      end
    end

    trait :with_collaborative_drafts_enabled do
      settings do
        {
          collaborative_drafts_enabled: true
        }
      end
    end

    trait :with_attachments_allowed_and_collaborative_drafts_enabled do
      settings do
        {
          attachments_allowed: true,
          collaborative_drafts_enabled: true
        }
      end
    end

    trait :with_minimum_votes_per_user do
      transient do
        minimum_votes_per_user { 3 }
      end

      settings do
        {
          minimum_votes_per_user:
        }
      end
    end

    trait :with_participatory_texts_enabled do
      settings do
        {
          participatory_texts_enabled: true
        }
      end
    end

    trait :with_amendments_enabled do
      settings do
        {
          amendments_enabled: true
        }
      end
    end

    trait :with_amendments_and_participatory_texts_enabled do
      settings do
        {
          participatory_texts_enabled: true,
          amendments_enabled: true
        }
      end
    end

    trait :with_comments_disabled do
      settings do
        {
          comments_enabled: false
        }
      end
    end

    trait :with_extra_hashtags do
      transient do
        automatic_hashtags { "AutoHashtag AnotherAutoHashtag" }
        suggested_hashtags { "SuggestedHashtag AnotherSuggestedHashtag" }
      end

      step_settings do
        {
          participatory_space.active_step.id => {
            automatic_hashtags:,
            suggested_hashtags:,
            creation_enabled: true
          }
        }
      end
    end

    trait :without_publish_answers_immediately do
      step_settings do
        {
          participatory_space.active_step.id => {
            publish_answers_immediately: false
          }
        }
      end
    end
  end

  factory :proposal_state, class: "Decidim::Proposals::ProposalState" do
    transient do
      skip_injection { false }
    end
    token { :not_answered }
    title { generate_state_title(:not_answered, skip_injection:) }
    announcement_title { generate_localized_title(:announcement_title, skip_injection:) }
    component { build(:proposal_component) }
    bg_color { Faker::Color.hex_color(:light) }
    text_color { Faker::Color.hex_color(:dark) }

    trait :evaluating do
      title { generate_state_title(:evaluating, skip_injection:) }
      token { :evaluating }
    end

    trait :accepted do
      title { generate_state_title(:accepted, skip_injection:) }
      token { :accepted }
    end

    trait :rejected do
      title { generate_state_title(:rejected, skip_injection:) }
      token { :rejected }
    end

    trait :withdrawn do
      title { generate_state_title(:withdrawn, skip_injection:) }
      token { :withdrawn }
    end
  end

  factory :proposal, class: "Decidim::Proposals::Proposal" do
    transient do
      users { nil }
      skip_injection { false }
      state { :not_answered }
    end

    title { generate_localized_title(:proposal_title, skip_injection:) }
    body { generate_localized_description(:proposal_body, skip_injection:) }
    component { create(:proposal_component, skip_injection:) }
    published_at { Time.current }
    deleted_at { nil }
    address { "#{Faker::Address.street_name}, #{Faker::Address.city}" }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    cost { 20_000 }
    cost_report { generate_localized_title(:proposal_cost_report, skip_injection:) }
    execution_period { generate_localized_title(:proposal_execution_period, skip_injection:) }

    after(:build) do |proposal, evaluator|
      if proposal.component
        existing_states = Decidim::Proposals::ProposalState.where(component: proposal.component)

        Decidim::Proposals.create_default_states!(proposal.component, nil, with_traceability: false) unless existing_states.any?
      end

      proposal.assign_state(evaluator.state)

      proposal.title = if evaluator.title.is_a?(String)
                         { proposal.try(:organization).try(:default_locale) || "en" => evaluator.title }
                       else
                         evaluator.title
                       end
      proposal.body = if evaluator.body.is_a?(String)
                        { proposal.try(:organization).try(:default_locale) || "en" => evaluator.body }
                      else
                        evaluator.body
                      end

      proposal.title = Decidim::ContentProcessor.parse_with_processor(:hashtag, proposal.title, current_organization: proposal.organization).rewrite
      proposal.body = Decidim::ContentProcessor.parse_with_processor(:hashtag, proposal.body, current_organization: proposal.organization).rewrite

      if proposal.component
        users = evaluator.users || [create(:user, :confirmed, organization: proposal.component.participatory_space.organization, skip_injection: evaluator.skip_injection)]
        users.each do |user|
          proposal.coauthorships.build(author: user)
        end
      end
    end

    trait :published do
      published_at { Time.current }
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :participant_author do
      after :build do |proposal, evaluator|
        proposal.coauthorships.clear
        user = build(:user, :confirmed, organization: proposal.component.participatory_space.organization, skip_injection: evaluator.skip_injection)
        proposal.coauthorships.build(author: user)
      end
    end

    trait :official do
      after :build do |proposal|
        proposal.coauthorships.clear
        proposal.coauthorships.build(author: proposal.organization)
      end
    end

    trait :official_meeting do
      after :build do |proposal, evaluator|
        proposal.coauthorships.clear
        component = build(:meeting_component, :published, participatory_space: proposal.component.participatory_space, skip_injection: evaluator.skip_injection)
        proposal.coauthorships.build(author: build(:meeting, :published, component:, skip_injection: evaluator.skip_injection))
      end
    end

    trait :evaluating do
      state { :evaluating }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :accepted do
      state { :accepted }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :rejected do
      state { :rejected }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :withdrawn do
      withdrawn_at { Time.current }
    end

    trait :accepted_not_published do
      state { :accepted }
      answered_at { Time.current }
      state_published_at { nil }
      answer { generate_localized_title }
    end

    trait :with_answer do
      state { :accepted }
      answer { generate_localized_title }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :not_answered do
      state { :not_answered }
    end

    trait :draft do
      published_at { nil }
    end

    trait :hidden do
      after :create do |proposal, evaluator|
        create(:moderation, hidden_at: Time.current, reportable: proposal, skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_votes do
      after :create do |proposal, evaluator|
        create_list(:proposal_vote, 5, proposal:, skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_likes do
      after :create do |proposal, evaluator|
        5.times.collect do
          create(:like, resource: proposal,
                        author: build(:user, :confirmed, organization: proposal.participatory_space.organization, skip_injection: evaluator.skip_injection),
                        skip_injection: evaluator.skip_injection)
        end
      end
    end

    trait :with_amendments do
      after :create do |proposal, evaluator|
        create_list(:proposal_amendment, 5, amendable: proposal, skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_photo do
      after :create do |proposal, evaluator|
        proposal.attachments << create(:attachment, :with_image, attached_to: proposal, skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_document do
      after :create do |proposal, evaluator|
        proposal.attachments << create(:attachment, :with_pdf, attached_to: proposal, skip_injection: evaluator.skip_injection)
      end
    end

    trait :moderated do
      after(:create) do |proposal, evaluator|
        create(:moderation, reportable: proposal, hidden_at: 2.days.ago, skip_injection: evaluator.skip_injection)
      end
    end
  end

  factory :proposal_vote, class: "Decidim::Proposals::ProposalVote" do
    transient do
      skip_injection { false }
    end
    proposal { build(:proposal, skip_injection:) }
    author { build(:user, organization: proposal.organization, skip_injection:) }
  end

  factory :proposal_amendment, class: "Decidim::Amendment" do
    transient do
      skip_injection { false }
    end
    amendable { build(:proposal, skip_injection:) }
    emendation { build(:proposal, component: amendable.component, skip_injection:) }
    amender { build(:user, :confirmed, organization: amendable.component.participatory_space.organization, skip_injection:) }
    state { Decidim::Amendment::STATES.keys.sample }
  end

  factory :proposal_note, class: "Decidim::Proposals::ProposalNote" do
    transient do
      skip_injection { false }
    end
    body do
      if skip_injection
        generate(:title)
      else
        "<script>alert(\"proposal_note_body\");</script> #{generate(:title)}"
      end
    end
    proposal { build(:proposal, skip_injection:) }
    author { build(:user, organization: proposal.organization, skip_injection:) }
  end

  factory :collaborative_draft, class: "Decidim::Proposals::CollaborativeDraft" do
    transient do
      skip_injection { false }
      users { nil }
    end

    title { generate_localized_title(:collaborative_draft_title, skip_injection:)["en"] }
    body { generate_localized_description(:collaborative_draft_body, skip_injection:)["en"] }
    component { create(:proposal_component, skip_injection:) }
    address { "#{Faker::Address.street_name}, #{Faker::Address.city}" }
    state { "open" }

    after(:build) do |collaborative_draft, evaluator|
      if collaborative_draft.component
        users = evaluator.users || [create(:user, organization: collaborative_draft.component.participatory_space.organization, skip_injection: evaluator.skip_injection)]
        users.each do |user|
          collaborative_draft.coauthorships.build(author: user)
        end
      end
    end

    trait :participant_author do
      after :build do |draft, evaluator|
        draft.coauthorships.clear
        user = build(:user, organization: draft.component.participatory_space.organization, skip_injection: evaluator.skip_injection)
        draft.coauthorships.build(author: user)
      end
    end

    trait :published do
      state { "published" }
      published_at { Time.current }
    end

    trait :open do
      state { "open" }
    end

    trait :withdrawn do
      state { "withdrawn" }
    end
  end

  factory :participatory_text, class: "Decidim::Proposals::ParticipatoryText" do
    transient do
      skip_injection { false }
    end

    title { generate_localized_title(:participatory_text_title, skip_injection:) }
    description { generate_localized_description(:participatory_text_description, skip_injection:) }
    component { create(:proposal_component, skip_injection:) }
  end

  factory :evaluation_assignment, class: "Decidim::Proposals::EvaluationAssignment" do
    transient do
      skip_injection { false }
    end
    proposal
    evaluator_role do
      space = proposal.component.participatory_space
      organization = space.organization
      build(:participatory_process_user_role, role: :evaluator, skip_injection:, user: build(:user, organization:, skip_injection:))
    end
  end
end
