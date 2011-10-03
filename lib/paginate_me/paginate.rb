module PaginateMe
  module PMController
    def paginate_me(item, options = {})
      # TODO this entire method needs to be cleaned up
      #set generic param defaults
      @options = options
      @options[:params_var] ||= :page
      @options[:per_page] ||= 10
      @options[:current_page] = self.params[@options[:params_var]].to_i || 1
      @options[:order] ||= "#{item.to_s}.created_at ASC"

      current_page = @options[:current_page] <= 0 ? 1 : @options[:current_page]
      
      model_name = item.to_s
      model = model_name.singularize.camelize.constantize

      @options[:base_url] ||= method("#{model_name}_path").call

      instance_variable_set("@#{model_name}", 
      model
        .includes(@options[:includes])
        .where(@options[:where])
        .order(@options[:order])
        .limit(@options[:per_page])
        .offset((current_page-1) * @options[:per_page]) )
      
      @options[:page_total] = (model.includes(@options[:includes]).where(@options[:where]).count / @options[:per_page].to_f).ceil

      # set bounds for the current page, this makes sure the current_page variable stays within
      # the max and min number of items
      if @options[:current_page] <= 0
        @options[:current_page] = 1
      elsif @options[:current_page] > @options[:page_total]
        @options[:current_page] = @options[:page_total] - 1
      end
    end
  end

  module PMView
    def paginate_for(item,options = {},&block)

      @page_block = block || @page_block
      raise ArgumentError, "Missing Block" if @page_block.nil?

      model_name = item.to_s

      options = options.merge @options

      paginate_classes = options[:class] || model_name
      paginate_classes = paginate_classes.join " " if paginate_classes.is_a? Array

      paginate_builder = PaginateMeBuilder.new(options)

      content = capture(paginate_builder,&@page_block)

      content_tag(:div,content, :class => "paginate_me #{paginate_classes}")
    end
    
    class PaginateMeBuilder
      include ActionView::Helpers

      def initialize(options)

        @slug = options[:slug] ||= "page"
        @base_url = options[:base_url]
        @per_page = options[:per_page]
        @page_total = options[:page_total]
        @current_page = options[:current_page]

        @next_page = (@current_page >= @page_total ? @current_page : @current_page + 1).to_s
        @prev_page = (@current_page <= 1 ? @current_page : @current_page - 1).to_s   
      end

      def link_to_next(options = {})
        options[:name] ||= "Next"

        add_to_template paginate_link_to @next_page, options if @current_page < @page_total
      end

      def link_to_last(options = {})
        options[:name] ||= "Last"
        
        add_to_template paginate_link_to @page_total, options if @current_page < @page_total 
      end

      def link_to_previous(options = {})
        options[:name] ||= "Previous"

        add_to_template paginate_link_to @prev_page, options if @current_page > 1
      end

      def link_to_first(options = {})
        options[:name] ||= "First"

        add_to_template paginate_link_to 1, options if @current_page > 1
      end

      def page_out_of_total(options = {})
        content = "#{@current_page} of #{@page_total}"
        add_to_template content_tag(:span,content, options)
      end

      private 
        def paginate_link_to(page, args)
          name = args[:name]
          args[:class] ||= name.downcase
          args[:title] ||= name.downcase
          args.delete :name
          link_to(name, @base_url + "/#{@slug}/#{page}" , args)
        end

        def add_to_template(string)
          template = "\n\t" + string
          template.html_safe
        end
    end
  end
end

