require 'erb'

# Class responsible for rendering ERB views with optional layout support.
class ViewRenderer
  # Renders an ERB view file, optionally using a layout.
  #
  # Reads the specified view file from the `./views/` directory.
  # If `use_layout` is true, the view content is inserted into the layout template.
  #
  # @param view_file [String] The name of the view file (without `.erb` extension).
  # @param use_layout [Boolean] Whether to wrap the view content in the layout (default: true).
  # @return [String] The rendered content, or an error message if the view or layout file is missing.
  def self.render(view_file, use_layout = true)
    view_path = "./views/#{view_file}.erb"
    layout_path = "./views/layout.erb"

    puts "Attempting to render view at: #{view_path}"  # Debugging output

    begin
      view_content = File.read(view_path)
    rescue Errno::ENOENT
      puts "View file not found: #{view_path}"
      return "<h1>Error: View file #{view_file} not found.</h1>"
    end

    if use_layout
      begin
        layout_content = File.read(layout_path)
      rescue Errno::ENOENT
        puts "Layout file not found: #{layout_path}"
        return "<h1>Error: Layout file not found.</h1>"
      end

      # Insert the view content into the layout.
      final_content = layout_content.gsub('<%= yield %>', view_content)
    else
      final_content = view_content
    end

    final_content
  end
end
