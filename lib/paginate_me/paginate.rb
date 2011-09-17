module PaginateMe
  module PMController
    def paginate_me(item, options = {})
        model_name = item.to_s
        model = model_name.singularize.camelize.constantize

        @options = {}
        @options[:base_url] = options[:url] || method("#{model_name}_path").call
        @options[:per_page] = options[:per_page] || 10
        @options[:page_total] = (model.count / @options[:per_page].to_f).ceil
        @options[:current_page] = self.params['page'].to_i || options[:page].to_i || 1
        
        current_page = @options[:current_page]
        page_total = @options[:page_total]

        if current_page <= 0
          current_page = 1
        elsif current_page > page_total
          current_page = page_total - 1
        end
        
        instance_variable_set("@#{model_name}", 
          model.limit(@options[:per_page]).offset((current_page-1) * @options[:per_page]))
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
    
  end
  class PaginateMeBuilder
      include ActionView::Helpers

      def initialize(options)

        @slug = options[:slug] || "page"

        @base_url = options[:base_url]
        @per_page = options[:per_page]
        @page_total = options[:page_total]
        @current_page = options[:current_page]

        @next_page = (@current_page >= @page_total ? @current_page : @current_page + 1).to_s
        @prev_page = (@current_page <= 1 ? @current_page : @current_page - 1).to_s     
      end

      def link_to_next(options = {})
        options[:name] ||= "Next"

        add_to_template paginate_link_to @page_total, options if 
                          @current_page < @page_total
      end

      def link_to_previous(options = {})
        options[:name] ||= "Previous"

        add_to_template paginate_link_to @page_total, options if 
                          @current_page > 1
      end

      def link_to_first(options = {})
        options[:name] ||= "First"

        add_to_template paginate_link_to @page_total, options if 
                          @current_page < @page_total
      end

      def link_to_last(options = {})
        options[:name] ||= "Last"
        
        add_to_template paginate_link_to @page_total, options if 
                          @current_page > 1
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

