# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with all the business logic when updating an existing
      # voting in the system.
      class UpdateVoting < Rectify::Command
        # Public: Initializes the command.
        #
        # voting - the Voting to update
        # form - A form object with the params.
        def initialize(voting, form)
          image_fields.each do |field|
            form.send("#{field}=".to_sym, voting.send(field)) if form.send(field).blank?
          end
          @voting = voting
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_voting!

          if voting.valid?
            broadcast(:ok, voting)
          else
            image_fields.each do |field|
              form.errors.add(field, voting.errors[field]) if voting.errors.include? field
            end
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :voting

        def image_fields
          [:banner_image, :introductory_image]
        end

        def update_voting!
          voting.assign_attributes(attributes)
          return unless voting.valid?

          voting.save!

          Decidim.traceability.perform_action!(:update, voting, form.current_user) do
            voting
          end
        end

        def attributes
          {
            title: form.title,
            description: form.description,
            slug: form.slug,
            start_time: form.start_time,
            end_time: form.end_time,
            scope: form.scope,
            promoted: form.promoted,
            voting_type: form.voting_type
          }.merge(uploader_attributes)
        end

        def uploader_attributes
          {
            banner_image: form.banner_image,
            remove_banner_image: form.remove_banner_image,
            introductory_image: form.introductory_image,
            remove_introductory_image: form.remove_introductory_image
          }.delete_if { |_k, val| val.is_a?(Decidim::ApplicationUploader) }
        end
      end
    end
  end
end
