module SearchHelper
  def search_form(path, label, id: nil)
    @html_id = 'search_' + (id || label)
    @path = path
    @label = label
    render partial: 'search/form'
  end

  def get_movie(result)
    attrs = result.to_h.select { |key| Movie.method_defined?(key) }
    m = Movie.new(attrs)
  end
end
