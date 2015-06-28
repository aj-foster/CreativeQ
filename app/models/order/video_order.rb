class VideoOrder < Order
  def self.needs
    ["Event Promotion", "Live Production", "Event Recap", "Exec Video",
     "Reveal / Teaser", "Other"]
  end

  def flavor
    "Video"
  end
end