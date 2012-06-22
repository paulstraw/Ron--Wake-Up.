class User < ActiveRecord::Base
  attr_accessible :fb_id, :token

  def wake_ron
    puts "WAKING RON! #{self.inspect}"
  end
end
