# -*- coding: utf-8 -*-
class User < TwitterAuth::GenericUser
  has_many :emerges

  def link
    "/users/" + self.login
  end

  def pretty_duration(dur)
    days = dur.divmod(24*60*60)
    hours = days[1].divmod(60*60)
    mins = hours[1].divmod(60)
    
    if days[0] > 0
      days[0].to_s + "日" + hours[0].to_s + "時間" + mins[0].to_s + "分"
    elsif hours[0] > 0
      hours[0].to_s + "時間" + mins[0].to_s + "分"
    elsif mins[0] > 0
      mins[0].to_s + "分" + mins[1].to_s + "秒"
    else
      mins[1].to_s + "秒"
    end      
  end

  def toLimitedEmergesList(emerges, limit, initfoot, foot)
    txt = emerges.collect{|e| e.package.fullname}.join(' ')+initfoot
    while txt.split(//u).length > limit
      if emerges.length == 1
        txt = foot
        break
      end
      emerges.pop
      txt = emerges.collect{|e| e.package.fullname}.join(' ')+"など"+foot
    end
    txt
  end

  def delayEmergeTweetTxts
    emerges_succ = self.emerges.where("tobe_tweet = ? AND duration <> 0", true)
    emerges_failed = self.emerges.where("tobe_tweet = ? AND duration = 0", true)

    return [] if emerges_succ.length + emerges_failed.length == 0

    self.emerges.update_all ["tobe_tweet = ?", false], ["tobe_tweet = ?", true]

    foot = " http://gentwoo.elisp.net"+self.link+" #GenTwoo"
    limit = 140 - foot.length

    if emerges_failed.length > 0
      failed_txt = toLimitedEmergesList(emerges_failed, limit,
                                        "のemergeに失敗しました。",
                                        emerges_failed.length.to_s+"個のemergeに失敗しました。")
      limit -= failed_txt.split(//u).length
    else
      failed_txt = ""
    end

    if emerges_succ.length > 0
      succ_time = pretty_duration(emerges_succ.collect{|e| e.duration}.sum)
      succ_txt = toLimitedEmergesList(emerges_succ, limit,
                                      "をemergeしました。(のべ"+succ_time+")",
                                      emerges_succ.length.to_s +
                                      "個をemergeしました。(のべ"+succ_time+")")
    else
      succ_txt = ""
    end

    if succ_txt.split(//u).length > limit
      emerges_succ = self.emerges.where("tobe_tweet = ? AND duration <> 0", true)
      succ_time = pretty_duration(emerges_succ.collect{|e| e.duration}.sum)
      succ_txt = toLimitedEmergesList(emerges_succ, 140 - foot.length,
                                      "をemergeしました。(のべ"+succ_time+")",
                                      emerges_succ.length.to_s +
                                      "個をemergeしました。(のべ"+succ_time+")")
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
    self.delayEmergeTweetTxts.each do |txt|
      if tweet
        begin
          self.twitter.post('/statuses/update.json', :status => txt)
        rescue TwitterAuth::Dispatcher::Error => e
          p e
        end
      else
        p txt
      end
    end
  end
end
