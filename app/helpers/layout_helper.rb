module LayoutHelper
  def title(page_title, show_title = true)
    content_for(:title) { page_title.to_s }
    @show_title = show_title
  end
  def show_title?
    @show_title
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end
  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  def navigation(*data)
    content_tag :ul do
      data.map do |link, name|
        content_tag :li, link_to("#{name}", link),
            :class => ("active" if controller.controller_name == link[1,link.length])
      end
    end
  end

end