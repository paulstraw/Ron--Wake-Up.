task :wake_ron => :environment do
  users = User.all

  users.each do |u|
    HTTParty.post("https://graph.facebook.com/Creechling/feed?access_token=#{u.token}&message=Ron,%20wake%20up.")
  end
end