# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"

module Decidim
  module Proposals
    class Seeds < Decidim::Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        component = create_component!

        Decidim::Proposals.create_default_states!(component, admin_user)

        number_of_records = fast_seeds? ? 10 : rand(25..50)

        (5..number_of_records).to_a.sample.times do |n|
          proposal = create_proposal!(component:)

          if proposal.state.nil? && component.settings.amendments_enabled?
            emendation = create_emendation!(proposal:)
            create_proposal_votes!(proposal: emendation)
          end

          (n % 3).times do |_m|
            create_proposal_votes!(proposal:)
          end

          (n % 3).times do
            create_proposal_notes!(proposal:)
          end

          Decidim::Comments::Seed.comments_for(proposal)

          create_collaborative_draft!(component:)
        end

        update_traceability!(component:)

        create_report!(reportable: Decidim::Proposals::Proposal.take, current_user: Decidim::User.take)
        hide_report!(reportable: Decidim::Proposals::Proposal.take)
      end

      def organization
        @organization ||= participatory_space.organization
      end

      def create_component!
        step_settings = if participatory_space.allows_steps?
                          { participatory_space.active_step.id => {
                            votes_enabled: true,
                            votes_blocked: [false, true].sample,
                            votes_hidden: [false, true].sample,
                            creation_enabled: true
                          } }
                        else
                          {}
                        end

        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :proposals).i18n_name,
          manifest_name: :proposals,
          published_at: Time.current,
          participatory_space:,
          settings: {
            minimum_votes_per_user: (0..2).to_a.sample,
            vote_limit: (0..5).to_a.sample,
            threshold_per_proposal: [0, (10..100).to_a.sample].sample,
            can_accumulate_votes_beyond_threshold: [true, false].sample,
            attachments_allowed: [true, false].sample,
            amendments_enabled: participatory_space.id.odd?,
            collaborative_drafts_enabled: true,
            geocoding_enabled: [true, false].sample
          },
          step_settings:
        }

        Decidim.traceability.perform_action!(
          "publish",
          Decidim::Component,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Component.create!(params)
        end
      end

      def create_proposal!(component:)
        proposal_state, answer, state_published_at = random_state_answer
        proposal_state = Decidim::Proposals::ProposalState.where(component:, token: proposal_state).first

        params = {
          component:,
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          body: Decidim::Faker::Localized.paragraph(sentence_count: 1),
          proposal_state:,
          answer:,
          answered_at: proposal_state.present? ? Time.current : nil,
          state_published_at:,
          published_at: Time.current
        }

        if component.settings.geocoding_enabled?
          params = params.merge({
                                  address: "#{::Faker::Address.street_address} #{::Faker::Address.zip} #{::Faker::Address.city}",
                                  latitude: ::Faker::Address.latitude,
                                  longitude: ::Faker::Address.longitude
                                })
        end

        proposal = Decidim.traceability.perform_action!(
          "publish",
          Decidim::Proposals::Proposal,
          admin_user,
          visibility: "all"
        ) do
          proposal = Decidim::Proposals::Proposal.new(params)
          coauthor = random_coauthor
          proposal.add_coauthor(coauthor)
          proposal.save!

          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_published_for_space",
            event_class: Decidim::Proposals::PublishProposalEvent,
            resource: proposal,
            followers: proposal.participatory_space.followers
          )

          proposal
        end

        create_attachment(attached_to: proposal, filename: "city.jpeg") if component.settings.attachments_allowed?

        proposal
      end

      def random_state_answer
        n = rand(5)

        if n > 3
          [:accepted, Decidim::Faker::Localized.sentence(word_count: 10), Time.current]
        elsif n > 2
          [:rejected, nil, Time.current]
        elsif n > 1
          [:evaluating, nil, Time.current]
        elsif n.positive?
          [:accepted, Decidim::Faker::Localized.sentence(word_count: 10), nil]
        else
          [:not_answered, nil, nil]
        end
      end

      def random_coauthor
        n = rand(4)
        n = 2 if n == 1 && !Decidim.module_installed?(:meetings)

        case n
        when 0
          Decidim::User.where(organization:).sample
        when 1
          meeting_component = participatory_space.components.find_by(manifest_name: "meetings")

          Decidim::Meetings::Meeting.where(component: meeting_component).sample
        else
          organization
        end
      end

      def random_nickname
        "#{::Faker::Twitter.unique.screen_name}-#{SecureRandom.hex(4)}"[0, 20]
      end

      def random_email(suffix:)
        r = SecureRandom.hex(4)

        "#{suffix}-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{r}@example.org"
      end

      def create_emendation!(proposal:)
        author = find_or_initialize_user_by(email: random_email(suffix: "amendment"))

        params = {
          component: proposal.component,
          title: Decidim::Faker::Localized.literal(proposal.title[I18n.locale]),
          body: Decidim::Faker::Localized.paragraph(sentence_count: 3),
          proposal_state: Decidim::Proposals::ProposalState.where(component: proposal.component, token: :evaluating).first,
          answer: nil,
          answered_at: Time.current,
          published_at: Time.current
        }

        emendation = Decidim.traceability.perform_action!(
          "create",
          Decidim::Proposals::Proposal,
          author,
          visibility: "public-only"
        ) do
          emendation = Decidim::Proposals::Proposal.new(params)
          emendation.add_coauthor(author)
          emendation.save!
          emendation
        end

        Decidim::Amendment.create!(
          amender: author,
          amendable: proposal,
          emendation:,
          state: "evaluating"
        )

        emendation
      end

      def create_proposal_votes!(proposal:)
        author = find_or_initialize_user_by(email: random_email(suffix: "vote"))

        Decidim::Proposals::ProposalVote.create!(proposal:, author:) unless proposal.published_state? && proposal.rejected?
      end

      def create_proposal_notes!(proposal:)
        author_admin = Decidim::User.where(organization:, admin: true).all.sample

        Decidim::Proposals::ProposalNote.create!(
          proposal:,
          author: author_admin,
          body: ::Faker::Lorem.paragraphs(number: 2).join("\n")
        )
      end

      def create_collaborative_draft!(component:)
        n = rand(5)
        state = if n > 3
                  "published"
                elsif n > 2
                  "withdrawn"
                else
                  "open"
                end
        author = Decidim::User.where(organization:).all.sample

        draft = Decidim.traceability.perform_action!("create", Decidim::Proposals::CollaborativeDraft, author) do
          draft = Decidim::Proposals::CollaborativeDraft.new(
            component:,
            title: ::Faker::Lorem.sentence(word_count: 2),
            body: ::Faker::Lorem.paragraphs(number: 2).join("\n"),
            state:,
            published_at: Time.current
          )
          draft.coauthorships.build(author: participatory_space.organization)
          draft.save!
          draft
        end

        case n
        when 2
          authors = Decidim::User.where(organization:).all.sample(5)
          authors.each do |local_author|
            Decidim::Coauthorship.create(coauthorable: draft, author: local_author)
          end
        when 3
          author2 = Decidim::User.where(organization:).all.sample
          Decidim::Coauthorship.create(coauthorable: draft, author: author2)
        end

        Decidim::Comments::Seed.comments_for(draft)
      end

      def update_traceability!(component:)
        Decidim.traceability.update!(
          Decidim::Proposals::CollaborativeDraft.all.sample,
          Decidim::User.where(organization:).all.sample,
          component:,
          title: ::Faker::Lorem.sentence(word_count: 2),
          body: ::Faker::Lorem.paragraphs(number: 2).join("\n")
        )
      end
    end
  end
end
