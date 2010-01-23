class Tweet < ActiveRecord::Base
  validates_uniqueness_of :tweet_id
  
  def to_s
    "#{from_user}: #{text}"
  end
  
  def self.update_from_twitter
    count = 0
    new_tweets = Twitter::Search.new(Hashtag.search_string).since(Tweet.last.try(:tweet_id) || 0)
		new_tweets ||= []
		new_tweets.each do |tweet|
      if Tweet.create(:tweet_id => tweet.id, :text => tweet.text, :from_user => tweet.from_user).valid?
        count += 1
      end
    end
    puts "added #{count} (total: #{Tweet.count})" if count > 0
  end
  
  
  def self.poll_indefinitely(pause = 2)
    loop do
      update_from_twitter
      sleep pause
    end
  end
end
