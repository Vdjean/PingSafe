class TutorialsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:install]

  def install
    # Detect browser type
    user_agent = request.user_agent.downcase
    @is_ios = user_agent.include?('iphone') || user_agent.include?('ipad')
    @is_safari = user_agent.include?('safari') && !user_agent.include?('chrome')
    @is_chrome = user_agent.include?('chrome')
  end

  def skip
    cookies[:skip_tutorial] = { value: 'true', expires: 1.year.from_now }
    redirect_to root_path
  end
end
