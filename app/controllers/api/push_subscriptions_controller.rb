# DÉSACTIVÉ TEMPORAIREMENT - Push subscriptions API
# module Api
#   class PushSubscriptionsController < ApplicationController
#     before_action :authenticate_user!
#     skip_before_action :verify_authenticity_token
#
#     def create
#       subscription = current_user.push_subscriptions.find_or_initialize_by(
#         endpoint: params[:endpoint]
#       )
#
#       subscription.assign_attributes(
#         p256dh_key: params[:p256dh_key],
#         auth_key: params[:auth_key]
#       )
#
#       if subscription.save
#         render json: { success: true, id: subscription.id }
#       else
#         render json: { success: false, errors: subscription.errors.full_messages }, status: :unprocessable_entity
#       end
#     end
#
#     def destroy
#       subscription = current_user.push_subscriptions.find_by(id: params[:id])
#
#       if subscription&.destroy
#         render json: { success: true }
#       else
#         render json: { success: false }, status: :not_found
#       end
#     end
#   end
# end
