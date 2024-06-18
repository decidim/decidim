# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"
require "decidim/meetings/test/factories"

FactoryBot.define do
  factory :proposal_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { generate_component_name(participatory_space.organization.available_locales, :proposals) }
    manifest_name { :proposals }
    participatory_space { create(:participatory_process, :with_steps, organization: organization, skip_injection: skip_injection) }
    trait :with_endorsements_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { endorsements_enabled: true }
        }
      end
    end

    trait :with_endorsements_disabled do
      step_settings do
        {
          participatory_space.active_step.id => { endorsements_enabled: false }
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
          vote_limit: vote_limit
        }
      end
    end

    trait :with_proposal_limit do
      transient do
        proposal_limit { 1 }
      end

      settings do
        {
          proposal_limit: proposal_limit
        }
      end
    end

    trait :with_proposal_length do
      transient do
        proposal_length { 500 }
      end

      settings do
        {
          proposal_length: proposal_length
        }
      end
    end

    trait :with_endorsements_blocked do
      step_settings do
        {
          participatory_space.active_step.id => {
            endorsements_enabled: true,
            endorsements_blocked: true
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
          threshold_per_proposal: threshold_per_proposal
        }
      end
    end

    trait :with_can_accumulate_supports_beyond_threshold do
      settings do
        {
          can_accumulate_supports_beyond_threshold: true
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
          minimum_votes_per_user: minimum_votes_per_user
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
            automatic_hashtags: automatic_hashtags,
            suggested_hashtags: suggested_hashtags,
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

  factory :proposal, class: "Decidim::Proposals::Proposal" do
    transient do
      users { nil }
      # user_groups correspondence to users is by sorting order
      user_groups { [] }
      skip_injection { false }
    end

    title { generate_localized_title(:proposal_title, skip_injection: skip_injection) }
    body { generate_localized_description(:proposal_body, skip_injection: skip_injection) }
    component { create(:proposal_component, skip_injection: skip_injection) }
    published_at { Time.current }
    address { "#{Faker::Address.street_name}, #{Faker::Address.city}" }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    cost { 20_000 }
    cost_report { generate_localized_title(:proposal_cost_report, skip_injection: skip_injection) }
    execution_period { generate_localized_title(:proposal_execution_period, skip_injection: skip_injection) }

    after(:build) do |proposal, evaluator|
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
        users.each_with_index do |user, idx|
          user_group = evaluator.user_groups[idx]
          proposal.coauthorships.build(author: user, user_group: user_group)
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
        user = build(:user, organization: proposal.component.participatory_space.organization, skip_injection: evaluator.skip_injection)
        proposal.coauthorships.build(author: user)
      end
    end

    trait :user_group_author do
      after :build do |proposal, evaluator|
        proposal.coauthorships.clear
        user = create(:user, organization: proposal.component.participatory_space.organization, skip_injection: evaluator.skip_injection)
        user_group = create(:user_group, :verified, organization: user.organization, users: [user], skip_injection: evaluator.skip_injection)
        proposal.coauthorships.build(author: user, user_group: user_group)
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
        component = build(:meeting_component, participatory_space: proposal.component.participatory_space, skip_injection: evaluator.skip_injection)
        proposal.coauthorships.build(author: build(:meeting, component: component, skip_injection: evaluator.skip_injection))
      end
    end

    trait :evaluating do
      state { "evaluating" }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :accepted do
      state { "accepted" }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :rejected do
      state { "rejected" }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :withdrawn do
      state { "withdrawn" }
    end

    trait :accepted_not_published do
      state { "accepted" }
      answered_at { Time.current }
      state_published_at { nil }
      answer { generate_localized_title }
    end

    trait :with_answer do
      state { "accepted" }
      answer { generate_localized_title }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :not_answered do
      state { nil }
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
        create_list(:proposal_vote, 5, proposal: proposal, skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_endorsements do
      after :create do |proposal, evaluator|
        5.times.collect do
          create(:endorsement, resource: proposal, skip_injection: evaluator.skip_injection,
                               author: build(:user, organization: proposal.participatory_space.organization, skip_injection: evaluator.skip_injection))
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
  end

  factory :proposal_vote, class: "Decidim::Proposals::ProposalVote" do
    transient do
      skip_injection { false }
    end
    proposal { build(:proposal, skip_injection: skip_injection) }
    author { build(:user, organization: proposal.organization, skip_injection: skip_injection) }
  end

  factory :proposal_amendment, class: "Decidim::Amendment" do
    transient do
      skip_injection { false }
    end
    amendable { build(:proposal, skip_injection: skip_injection) }
    emendation { build(:proposal, component: amendable.component, skip_injection: skip_injection) }
    amender { build(:user, organization: amendable.component.participatory_space.organization, skip_injection: skip_injection) }
    state { Decidim::Amendment::STATES.sample }
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
    proposal { build(:proposal, skip_injection: skip_injection) }
    author { build(:user, organization: proposal.organization, skip_injection: skip_injection) }
  end

  factory :collaborative_draft, class: "Decidim::Proposals::CollaborativeDraft" do
    transient do
      users { nil }
      skip_injection { false }
      # user_groups correspondence to users is by sorting order
      user_groups { [] }
    end

    title { generate_localized_title(:collaborative_draft_title, skip_injection: skip_injection)["en"] }
    body { generate_localized_description(:collaborative_draft_body, skip_injection: skip_injection)["en"] }
    component { create(:proposal_component, skip_injection: skip_injection) }
    address { "#{Faker::Address.street_name}, #{Faker::Address.city}" }
    state { "open" }

    after(:build) do |collaborative_draft, evaluator|
      if collaborative_draft.component
        users = evaluator.users || [create(:user, organization: collaborative_draft.component.participatory_space.organization, skip_injection: evaluator.skip_injection)]
        users.each_with_index do |user, idx|
          user_group = evaluator.user_groups[idx]
          collaborative_draft.coauthorships.build(author: user, user_group: user_group)
        end
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
    title { generate_localized_title(:participatory_text_title, skip_injection: skip_injection) }
    description { generate_localized_description(:participatory_text_description, skip_injection: skip_injection) }
    component { create(:proposal_component, skip_injection: skip_injection) }
  end

  factory :valuation_assignment, class: "Decidim::Proposals::ValuationAssignment" do
    transient do
      skip_injection { false }
    end
    proposal
    valuator_role do
      space = proposal.component.participatory_space
      organization = space.organization
      build :participatory_process_user_role, role: :valuator, skip_injection: skip_injection, user: build(:user, organization: organization, skip_injection: skip_injection)
    end
  end
end
