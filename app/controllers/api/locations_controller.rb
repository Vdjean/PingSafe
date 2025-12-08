module Api
  class LocationsController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token

    def create
      latitude = params[:latitude].to_f
      longitude = params[:longitude].to_f

      current_user.push_subscriptions.update_all(
        last_latitude: latitude,
        last_longitude: longitude,
        last_location_at: Time.current
      )

      CheckProximityJob.perform_later(current_user.id, latitude, longitude)

      render json: { success: true }
    end
  end
end
