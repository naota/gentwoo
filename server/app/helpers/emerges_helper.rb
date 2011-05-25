# -*- coding: utf-8 -*-
module EmergesHelper
  def viewDuration(dur)
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

  def average(pkg)
    avg = pkg.emerges.average("duration",
                              {:conditions => "duration!=0"})
    if avg
      "平均所用時間 "+viewDuration(avg.to_i)
    else
      "成功例なし"
    end
  end
end
