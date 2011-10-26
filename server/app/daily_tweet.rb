# -*- coding: utf-8 -*-
class DailyTweet < ActiveRecord::Base
  gentwoo = User.find_by_name("gentwoo")
  count = Emerge.count(:conditions => ["buildtime > ?", 1.day.ago])
  pkg = Package.find(:all, 
                     :select => "count(emerges.id) AS cnt, packages.*",
                     :joins => :emerges,
                     :conditions => ["buildtime > ?", 1.day.ago],
                     :group => "package_id",
                     :order => "cnt DESC",
                     :limit => 1)
  usr = User.find(:all, 
                  :select => "count(emerges.id) AS cnt, users.*",
                  :joins => :emerges,
                  :conditions => ["buildtime > ?", 1.day.ago],
                  :group => "user_id",
                  :order => "cnt DESC",
                  :limit => 1)

  txt = "今日は#{count}回のemergeがありました。" +
    "一番emergeされたパッケージは#{pkg[0].fullname}(#{pkg[0].cnt}回)で、" +
    "一番emergeしたのは#{usr[0].login}さん(#{usr[0].cnt}回)です。"
  gentwoo.twitter.post('/statuses/update.json', :status => txt)
end
