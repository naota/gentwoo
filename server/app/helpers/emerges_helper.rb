# -*- coding: utf-8 -*-
module EmergesHelper
  def viewDuration(dur)
    days = dur.divmod(24*60*60)
    hours = days[1].divmod(60*60)
    mins = hours[1].divmod(60)
    
    if days[0] > 0
      days[0].to_s + t(:day) + hours[0].to_s + t(:hour) + mins[0].to_s + t(:minute)
    elsif hours[0] > 0
      hours[0].to_s + t(:hour) + mins[0].to_s + t(:minute)
    elsif mins[0] > 0
      mins[0].to_s + t(:minute) + mins[1].to_s + t(:second)
    else
      mins[1].to_s + t(:second)
    end      
  end

  def average(pkg)
    avg = pkg.emerges.average("duration",
                              {:conditions => "duration!=0"})
    if avg
      t(:avg_duration)+" "+viewDuration(avg.to_i)
    else
      t(:no_success)      
    end
  end
end
