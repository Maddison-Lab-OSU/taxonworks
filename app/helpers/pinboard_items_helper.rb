module PinboardItemsHelper

  def pin_item_to_pinboard_link(object, user)
    if !object.pinned?(user)
      link_to(content_tag(:span, 'Pin', class: 'pin-button'), pinboard_items_path(pinboard_item: {pinned_object_id: object.id, pinned_object_type: object.metamorphosize.class.name}), class: 'navigation-item' , method: :post)
    else
      content_tag(:span, 'Pinned', class: 'pin-button disable-button')
    end
  end

end
