class GraphicOrder < Order
  def self.needs
    ["Handbill", "Poster", "A-Frame", "Banner", "Newspaper", "T-Shirt",
     "Logo", "Brochure", "Program", "FB Event Photo", "OSI Banner",
     "OSI Front Desk TV", "FB Cover Photo", "FB Profile Photo", "Twitter Photo",
     "Instagram Photo", "KnightConnect", "Business Card", "Union TV",
     "Photobooth", "Other"]
  end

  def flavor
    "Graphics"
  end
end