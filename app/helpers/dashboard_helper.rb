module DashboardHelper
  include ActionView::Helpers::AssetTagHelper

  def sortable_header(title, column_key, url_options, update_div_id)
    sorting_on = !params[:sort_key].nil?
    options = {:sort_key => column_key}
    options = options.merge({:sort_asc => true}) if sorting_on && params[:sort_asc].nil?
    res = link_to_remote(title, :url => url_options.merge(options), :update => update_div_id)
    res += image_tag("sort_#{params[:sort_asc].nil? ? 'desc' : 'asc'}.png") if sorting_on && column_key.eql?(params[:sort_key])
    res
  end

end

