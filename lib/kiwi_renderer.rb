class KiwiRenderer < Redcarpet::Render::HTML
  def header(text, level)
    text
  end

  def image(url, text, title)
    text
  end
end
