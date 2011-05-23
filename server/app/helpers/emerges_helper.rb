# -*- coding: utf-8 -*-
module EmergesHelper
  def viewDuration(dur)
    days = dur.divmod(24*60*60)
    hours = days[1].divmod(60*60)
    mins = hours[1].divmod(60)
    
    if days[0] > 1
      days[0].to_s + "日" + hours[0].to_s + "時間" + mins[0].to_s + "分"
    elsif hours[0] > 1
      hours[0].to_s + "時間" + mins[0].to_s + "分"
    else
      mins[0].to_s + "分"
    end      
  end
end
