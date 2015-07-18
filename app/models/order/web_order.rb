class WebOrder < Order
  def self.needs
    ["New Event Site", "New Org Site", "Re-Brand", "Change Text",
     "Change Media", "Change Layout", "Change Design", "New Feature", "Other"]
  end

  def flavor
    "Web"
  end
end