module ApplicationHelper
  # Translates rails message levels to the ones that bootstrap uses
  def flash_class(level)
    case level
      when :notice then "info"
      when :error then "error"
      when :alert then "warning"
    end
  end

  # Returns if the current site equals <page_name>
  def is_active?(page_name)
     params[:action] == page_name
  end

  # printf "debugging" for the win
  def show_in_log thing
    puts "\n\n\n\n\n"+thing.inspect+"\n\n\n\n\n"
  end

end
