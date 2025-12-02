class PagesController < ApplicationController
  def home
  end

  def new
    @Ping = Ping.new
  end
end
