# frozen_string_literal: true

module Decidim
  # The controller to show all the conversations for a user or group
  # This controller places conversations in the public profile page.
  # Only for groups at the moment but it will make conversations_controller
  # obsolete in the future
  class UserConversationsController < Decidim::ApplicationController
    include Paginable
    include UserGroups
    include FormFactory
    include Messaging::ConversationHelper

    before_action :authenticate_user!
    before_action :ensure_profile_manager

    helper Decidim::ResourceHelper
    helper_method :user, :conversations, :conversation

    # overwrite original rescue_from to ensure we print messages from ajax methods (update)
    rescue_from Decidim::ActionForbidden, with: :ajax_user_has_no_permission

    def index
      enforce_permission_to :list, :conversation, interlocutor: user
    end

    # shows a conversation thread and presents a form to reply in ajax
    def show
      enforce_permission_to :show, :conversation, interlocutor: user, conversation: conversation

      conversation.mark_as_read(current_user)
    end

    # receive replies in ajax, messages are returned through the view update.js.erb and printed
    # over the form instead of using flash messages
    def update
      enforce_permission_to :update, :conversation, interlocutor: user, conversation: conversation

      @form = form(Messaging::MessageForm).from_params(params, sender: user)

      Messaging::ReplyToConversation.call(conversation, @form) do
        on(:ok) do |message|
          render action: :update, locals: { message: }
        end

        on(:invalid) do
          render_unprocessable_entity I18n.t("user_conversations.update.error", scope: "decidim")
        end
      end
    end

    # Shows the form to initiate a conversation with one or more users/groups (the recipients)
    # recipients are passed via GET parameters:
    #   - if no recipient are valid, redirects back to the users profile page
    #   - if the user already has a conversation with the user(s), redirects to the initiated conversation
    def new
      @form = form(Messaging::ConversationForm).from_params(params, sender: user)

      return redirect_back(fallback_location: profile_path(user.nickname)) if @form.recipient.empty?

      @conversation = new_conversation(@form.recipient)

      # redirect to existing conversation if already started
      return redirect_to profile_conversation_path(nickname: user.nickname, id: @conversation.id) if @conversation.id

      enforce_permission_to :create, :conversation, interlocutor: user, conversation: @conversation

      render :show
    end

    def create
      @form = form(Messaging::ConversationForm).from_params(params, sender: user)
      @conversation = new_conversation(@form.recipient)

      enforce_permission_to :create, :conversation, interlocutor: user, conversation: @conversation

      # do not allow to create multiple conversation to the same actors if already started
      if @conversation.id
        flash[:alert] = I18n.t("user_conversations.create.existing_error", scope: "decidim")
        return redirect_to profile_conversation_path(nickname: user.nickname, id: @conversation.id)
      end
      Messaging::StartConversation.call(@form) do
        on(:ok) do |_conversation|
          flash[:notice] = I18n.t("user_conversations.create.success", scope: "decidim")
          return redirect_to profile_conversations_path(nickname: user.nickname)
        end
        on(:invalid) do
          flash[:alert] = I18n.t("user_conversations.create.error", scope: "decidim")
          render action: :show
        end
      end
    end

    private

    # Rescue ajax calls and print the update.js view which prints the info on the message ajax form
    # Only if the request is AJAX, otherwise behave as Decidim standards
    def ajax_user_has_no_permission
      return user_has_no_permission unless request.xhr?

      render_unprocessable_entity I18n.t("actions.unauthorized", scope: "decidim.core")
    end

    def render_unprocessable_entity(message)
      render action: :update, locals: { error: message }, status: :unprocessable_entity
    end

    def user
      @user ||= Decidim::UserBaseEntity.find_by(nickname: params[:nickname], organization: current_organization)
    end

    def conversations
      paginate(Messaging::UserConversations.for(user))
    end

    def conversation
      @conversation ||= Messaging::Conversation.find(params[:id])
    end

    def new_conversation(recipients)
      conversation = conversation_between_multiple([user] + recipients)
      return conversation if conversation

      Messaging::Conversation.new(participants: [user] + recipients)
    end

    def ensure_profile_manager
      return if user.is_a?(UserGroup) && current_user.manageable_user_groups.include?(user)

      # For the moment, this controller is only for UserGroup profiles,
      # next line may be removed if in the future user conversations are handled in the
      # profile page as well
      return redirect_to conversations_path if user == current_user

      # if the previous line is removed, next must be uncommented to ensure only authorized
      # users access to the page
      # return if user == current_user

      raise ActionController::RoutingError, "Conversation not found"
    end
  end
end
