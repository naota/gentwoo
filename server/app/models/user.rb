# -*- coding: utf-8 -*-
class User < TwitterAuth::GenericUser
  has_many :emerges
  has_one :cache_pop_user

  def to_param
    self.login
  end

  def pretty_duration(dur)
    days = dur.divmod(24*60*60)
    hours = days[1].divmod(60*60)
    mins = hours[1].divmod(60)
    
    if days[0] > 0
      days[0].to_s + "days" + hours[0].to_s + "h" + mins[0].to_s + "m"
    elsif hours[0] > 0
      hours[0].to_s + "h" + mins[0].to_s + "m"
    elsif mins[0] > 0
      mins[0].to_s + "m" + mins[1].to_s + "s"
    else
      mins[1].to_s + "s"
    end      
  end

  def toLimitedEmergesList(emerges, limit, inithead, head)
    txt = inithead+emerges.collect{|e| e.package.fullname}.join(' ')
    while txt.split(//u).length > limit
      if emerges.length == 1
        txt = head
        break
      end
      emerges.pop
      txt = head+emerges.collect{|e| e.package.fullname}.join(' ')+" etc."
    end
    txt
  end

  def delayEmergeTweetTxts
    emerges_succ = self.emerges.where("tobe_tweet = ? AND duration <> 0", true).order("buildtime desc")
    emerges_failed = self.emerges.where("tobe_tweet = ? AND duration = 0", true).order("buildtime desc")

    return [] if emerges_succ.length + emerges_failed.length == 0

    foot = " http://gentwoo.elisp.net/users/"+self.login+" #GenTwoo"
    limit = 140 - foot.length

    if emerges_failed.length > 0
      failed_txt = toLimitedEmergesList(emerges_failed, limit,
                                        "Failed to emerge ",
                                        "Failed to emerge "+emerges_failed.length.to_s+" packages: ")
      limit -= failed_txt.split(//u).length
    else
      failed_txt = ""
    end

    if emerges_succ.length > 0
      succ_time = pretty_duration(emerges_succ.collect{|e| e.duration}.sum)
      succ_txt = toLimitedEmergesList(emerges_succ, limit,
                                      "emerge'd (in "+succ_time+") ",
                                      "emerge'd "+emerges_succ.length.to_s+" packages (in "+succ_time+"): ")
    else
      succ_txt = ""
    end

    if succ_txt.split(//u).length > limit
      emerges_succ = self.emerges.where("tobe_tweet = ? AND duration <> 0", true).order("buildtime desc")
      succ_time = pretty_duration(emerges_succ.collect{|e| e.duration}.sum)
      succ_txt = toLimitedEmergesList(emerges_succ, 140 - foot.length,
                                      "emerge'd (in "+succ_time+")",
                                      "emerge'd "+emerges_succ.length.to_s+" packages (in "+succ_time+"): ")
      if failed_txt == ""
        [succ_txt+foot]
      else
        [succ_txt+foot, failed_txt+foot]
      end
    else
      [succ_txt+failed_txt+foot, ]
    end
  end

  def delayEmergeTweet(tweet = true)
    return unless self.tweet_emerged
    if self.last_tweet == nil or self.tweet_interval.minutes.since(self.last_tweet) < Time.now
      self.delayEmergeTweetTxts.each do |txt|
        if tweet
          begin
            self.twitter.post('/statuses/update.json', :status => txt)
            self.emerges.update_all ["tobe_tweet = ?", false], ["tobe_tweet = ?", true]
            self.last_tweet = Time.now
            self.save
          rescue TwitterAuth::Dispatcher::Error => e
            p e
          end
        else
          p txt
          self.emerges.update_all ["tobe_tweet = ?", false], ["tobe_tweet = ?", true]
          self.last_tweet = Time.now
          self.save
        end
      end
    end
  end
end
