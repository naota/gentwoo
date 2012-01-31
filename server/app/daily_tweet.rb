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

  txt = "Today we have #{count} emerge" +
    "Most emerge'd package is #{pkg[0].fullname}(#{pkg[0].cnt} times) and " +
    "who most emerge'd is #{usr[0].login}(#{usr[0].cnt}times)"
  gentwoo.twitter.post('/statuses/update.json', :status => txt)
end
