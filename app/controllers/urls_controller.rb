require "browser"
class UrlsController < ApplicationController
  def index
    # recent 10 short urls
    @url = Url.new
    @urls = Url.latest(10)
  end

  def create
    short_url = create_short_url
    if is_valid?(url_params['original_url'])  && Url.create(url_params.merge(short_url:short_url))
      flash[:notice] = "Successfully added the short url"
    else
      flash[:error] = "Not able to create a short url"
    end
    redirect_to root_path
  end

  def show
    @url = Url.find_by(short_url:params['url'])
    # implement queries
    ['daily','browsers','platforms'].each do |name|
      instance_variable_set("@{name}", [])
    end
  
    Click.current_month_clicks(@url.id).each do |click| 
      @daily_clicks <<  [click['day'],click['clicks'].to_i]
    end
    
    Click.browser_stats(@url.id).each do |data|
      @browsers_clicks << [data['browser'],data['clicks'].to_i]
    end

    Click.platform_stats(@url.id).each do |data|
      @platform_clicks << [data['platform'],data['clicks'].to_i]
    end
  end

  def visit
    url = Url.find_by(short_url: params["short_url"])
    browser = Browser.new(request.user_agent, accept_language: "en-us")
    if is_valid?(url.original_url) && Click.create(url_id: url.id, browser: browser.name, platform: browser.platform.name)
      redirect_to url.original_url
    else
      render 'errors/404.html'
    end
  end

  private
  def url_params
    params.require(:url).permit(:original_url)
  end

  def create_short_url(length=5)
    chars = [*'A'..'Z']
    5.times.inject("") { |s,c| s<< chars[rand(chars.size)] }
  end

  def is_valid?(url)
    response = HTTParty.get(url)
    response.code == 200 ? true : false
  end
end
