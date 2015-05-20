module OrdersHelper

  # Creates an HSL representation of an order's due date. Orders are green up
  # until two weeks from the due date, when they begin to turn yellow, orange,
  # and red.
  #
  def color order
    hue = [[(order.due - Date.today).to_f / 14.0 * 75 + 25, 100].min, 25].max
    saturation = "100%"
    lightness = "#{50.0 - 10 * (hue - 50).abs / 50.0}%"

    return "hsl(" + hue.to_s + ", " + saturation + ", " + lightness + ")"
  end

  # Gives a formatted version of an order's due date.
  #
  # Format: Monday, January 1st
  #
  def due_date order
    order.due.strftime("%A, %B #{order.due.day.ordinalize}")
  end
end
