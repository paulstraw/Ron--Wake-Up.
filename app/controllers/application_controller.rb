class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
    @state = session[:state] = SecureRandom.hex(10)
  end

  def done
    unless params[:state] == session[:state]
      redirect_to root_url
      return
    end

    token_response = HTTParty.get("https://graph.facebook.com/oauth/access_token?client_id=289867491112170&redirect_uri=http://ronwakeup.paulstraw.com/done&client_secret=9eec06d26bd28015051b2d0e627cb53d&code=#{params[:code]}")

    unless token_response.code == 200
      render :text => "Ugh. There's some kind of problem. Try again later."
      return
    end

    token = Rack::Utils.parse_nested_query(token_response)['access_token']

    me_response = HTTParty.get("https://graph.facebook.com/me?access_token=#{token}")

    unless me_response.code == 200
      render :text => "Ugh. There's some kind of problem. Try again later."
      return
    end

    fb_id = JSON.parse(me_response.body)['id']

    user = User.find_by_fb_id(fb_id)

    if user
      user.token = token
    else
      user = User.new(:fb_id => fb_id, :token => token)
    end

    user.save

    redirect_to root_url, :notice => "You're all set. Check Ron's wall at 1:10 AM. Also, you'll probably have to come back here to reauthorize the application in 60 days or so."
  end
end
