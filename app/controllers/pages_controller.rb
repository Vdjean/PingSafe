class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  before_action :check_tutorial, only: [:home]
  before_action :authenticate_user!, only: [:home]

  def home
    @visible_pings = Ping.visible.includes(:user)
    @visible_pings_all = Ping.visible
  end

  private

  def check_tutorial
    # Check URL params as fallback for cookie issues (especially in Chrome)
    if params[:skip] == '1' || params[:pwa] == '1'
      # Make sure cookies are set
      cookies[:skip_tutorial] = { value: 'true', expires: 1.year.from_now } if params[:skip] == '1'
      cookies[:is_pwa] = { value: 'true', expires: 1.year.from_now } if params[:pwa] == '1'
      return
    end

    # If not authenticated and hasn't seen tutorial, show it
    unless user_signed_in? || cookies[:skip_tutorial] == 'true' || cookies[:is_pwa] == 'true'
      redirect_to tutorials_install_path and return
    end
  end

  def profile
    @user = current_user
  end

  def new
    @Ping = Ping.new
  end

  def this_ping
   @ping = Ping.find(params[:id])
  end
end
