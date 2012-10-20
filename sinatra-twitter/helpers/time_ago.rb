module Sinatra

  module TimeAgo

    def time_ago_in_words(time)
      distance_in_seconds = (Time.now - time).round

      case distance_in_seconds
      when 0..10
        return "just now"
      when 10..60
        return "less than a minute ago"
      end
      distance_in_minutes = (distance_in_seconds/60).round
      case distance_in_minutes
      when 0..1
        return "a minute ago"
      when 2..45
        return distance_in_minutes.round.to_s + " minutes ago"
      when 46..89
        return "about an hour ago"
      when 90..1439
        return (distance_in_minutes/60).round.to_s + " hours ago"
      when 1440..2879
        return "about a day ago"
      when 2880..43199
        (distance_in_minutes / 1440).round.to_s + " days ago"
      when 43200..86399
        "about a month ago"
      when 86400..525599
        (distance_in_minutes / 43200).round.to_s + " months ago"
      when 525600..1051199
        "about a year ago"
      else
        "over " + (distance_in_minutes / 525600).round.to_s + " years ago"
      end
    end
  end

  helpers TimeAgo
end
