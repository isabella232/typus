module Admin::Resources::FiltersHelper

  def build_filters(resource = @resource, request_params = params)
    if (typus_filters = resource.typus_filters).any?
      locals = {}

      locals[:filters] = typus_filters.map do |key, value|
                           { key: key, value: send("#{value}_filter", key) }
                         end

      rejections = %w(controller action locale utf8 sort_order order_by) + locals[:filters].map { |f| f[:key] }
      locals[:hidden_filters] = request_params.dup.delete_if { |k, _| rejections.include?(k) }

      render 'helpers/admin/resources/filters', locals
    end
  end

end
