# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user creates a Meeting from the admin
      # panel.
      class CreateAgenda < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :visible, :meeting

        protected

        def resource_class = Decidim::Meetings::Agenda

        def run_after_hooks
          form.agenda_items.each do |form_agenda_item|
            create_agenda_item(form_agenda_item)
          end
        end

        def create_agenda_item(form_agenda_item)
          agenda_item_attributes = {
            title: form_agenda_item.title,
            description: process_description(form_agenda_item.description),
            position: form_agenda_item.position,
            duration: form_agenda_item.duration,
            parent_id: form_agenda_item.parent_id,
            agenda: resource
          }

          create_nested_model(form_agenda_item, agenda_item_attributes, form.agenda_items) do |agenda_item|
            form_agenda_item.agenda_item_children.each do |form_agenda_item_child|
              agenda_item_child_attributes = {
                title: form_agenda_item_child.title,
                description: process_description(form_agenda_item_child.description),
                position: form_agenda_item_child.position,
                duration: form_agenda_item_child.duration,
                parent_id: agenda_item.id,
                agenda: resource
              }

              create_nested_model(form_agenda_item_child, agenda_item_child_attributes, agenda_item.agenda_item_children)
            end
          end
        end

        def create_nested_model(form, attributes, _agenda_item_children)
          record = Decidim::Meetings::AgendaItem.find_or_create_by!(attributes)

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

        def process_description(description)
          Decidim::ContentProcessor.parse(description, current_organization: form.current_organization).rewrite
        end
      end
    end
  end
end
