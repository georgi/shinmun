module Shinmun::Helpers

  # Render a link for the navigation bar. If the text of the link
  # matches the @header variable, the css class will be set to acitve.
  def navi_link(text, path)
    link_to text, path, :class => (text == @header) ? 'active' : nil
  end

end
