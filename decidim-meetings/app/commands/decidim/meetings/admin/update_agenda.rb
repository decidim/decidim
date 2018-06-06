# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user creates a Meeting from the admin
      # panel.
      class UpdateAgenda < Rectify::Command
        def initialize(form, agenda)
          @form = form
          @agenda = agenda
        end

        # Creates the agenda if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            update_agenda!
            update_agenda_items
          end

          broadcast(:ok, @agenda)
        end

        private

        attr_reader :form

        def update_agenda_items
          @form.agenda_items.each do |form_agenda_item|
            update_agenda_item(form_agenda_item)
          end
        end

        def update_agenda_item(form_agenda_item)
          agenda_item_attributes = {
            title: form_agenda_item.title,
            description: form_agenda_item.description,
            position: form_agenda_item.position,
            duration: form_agenda_item.duration,
            parent_id: form_agenda_item.parent_id
          }

          update_nested_model(form_agenda_item, agenda_item_attributes, @agenda.agenda_items) do |agenda_item|
            form_agenda_item.agenda_item_children.each do |form_agenda_item_child|
              agenda_item_child_attributes = {
                title: form_agenda_item_child.title,
                description: form_agenda_item_child.description,
                position: form_agenda_item_child.position,
                duration: form_agenda_item_child.duration,
                parent_id: agenda_item.id,
                agenda: @agenda
              }

              update_nested_model(form_agenda_item_child, agenda_item_child_attributes, agenda_item.agenda_item_children)
            end
          end
        end

        def update_nested_model(form, attributes, agenda_item_children)
          record = agenda_item_children.find_by(id: form.id) || agenda_item_children.build(attributes)

          yield record if block_given?

          if record.persisted?
            if form.deleted?
              record.destroy!
            else
              record.update!(attributes)
            end
          else
            record.save!
          end
        end

        def update_agenda!
          Decidim.traceability.update!(
            @agenda,
            form.current_user,
            title: form.title,
            visible: form.visible
          )
        end
      end
    end
  end
end
