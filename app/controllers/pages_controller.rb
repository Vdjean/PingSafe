class PagesController < ApplicationController
  def home
    # Check if running as PWA (standalone mode)
    is_pwa = request.headers['HTTP_USER_AGENT']&.include?('standalone') ||
             request.headers['HTTP_X_PURPOSE'] == 'preview'

    # If not PWA and not authenticated, show tutorial
    unless is_pwa || user_signed_in? || cookies[:skip_tutorial] == 'true'
      redirect_to tutorials_install_path and return
    end

    @visible_pings = Ping.visible.includes(:user)
    @visible_pings_all = Ping.visible
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
