module Admin::Resources::TableHelper

  def build_table(model, fields, items, link_options = {}, association = nil, association_name = nil)
    locals = {
      model: model,
      fields: fields,
      items: items,
      link_options: link_options,
      headers: table_header(model, fields),
      association_name: association_name,
    }

    render 'helpers/admin/resources/table', locals
  end

  def table_header(model, fields, request_params = params)
    fields.map do |key, _|

      key = key.gsub('.', ' ') if key.to_s.match(/\./)
      content = model.human_attribute_name(key)

      if request_params[:action].eql?('index') && model.typus_options_for(:sortable)
        association = model.reflect_on_association(key.to_sym)
        order_by = association ? association.foreign_key : key

        if (model.model_fields.map(&:first).map(&:to_s).include?(key) || model.reflect_on_all_associations(:belongs_to).map(&:name).include?(key.to_sym))
          sort_order = case request_params[:sort_order]
                       when 'asc' then %w(desc dropup)
                       when 'desc' then %w(asc dropdown)
                       else [nil, nil]
                       end

          switch = "<span class='#{sort_order.last}'><span class='caret'></span></span>" if request_params[:order_by].eql?(order_by)
          options = { order_by: order_by, sort_order: sort_order.first }
          message = [content, switch].compact.join(' ').html_safe
          content = link_to(message, request_params.merge(options))
        end
      end

      content
    end
  end

  def table_fields_for_item(item, fields)
    fields.map { |k, v| send("table_#{v}_field", k, item) }
  end

  def table_actions(model, item)
    @resource_actions.reject! do |_, url, _, _|
      admin_user.cannot?(url[:action], model.name)
    end

    @resource_actions.map do |body, url, options, proc|
      next if proc && proc.respond_to?(:call) && proc.call(item) == false

      # Hack to fix options URL
      if options && options['data-toggle']
        options[:url] = url_for(controller: "/admin/#{model.to_resource}", action: url[:action], id: item.id, _popup: true)
      end

      {
        message: t(body),
        url: params.dup.cleanup.merge({controller: "/admin/#{model.to_resource}", id: item.id}).merge(url),
        options: options,
      }
    end
  end

end
