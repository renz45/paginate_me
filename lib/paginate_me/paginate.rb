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
      model_name = item.to_s

      options = options.merge @options

      paginate_builder = PaginateMeBuilder.new(options)

      content = capture(paginate_builder,&block)

      content_tag(:div,content, :class => "paginate_me #{model_name}")
    end
    
  end
  class PaginateMeBuilder
      include ActionView::Helpers

      def initialize(options)

        @first_label = options[:first_label] || "First"

        @next_label = options[:next_label] || "Next"
        @previous_label = options[:previous_label] || "Previous"

        @last_label = options[:last_label] || "Last"

        @base_url = options[:base_url]
        @per_page = options[:per_page]
        @page_total = options[:page_total]
        @current_page = options[:current_page]

        @next_page = (@current_page >= @page_total ? @current_page : @current_page + 1).to_s
        @prev_page = (@current_page <= 1 ? @current_page : @current_page - 1).to_s     
      end

      def link_to_next
        add_to_template link_to(@next_label, @base_url + "/page/#{@next_page}", :class => "next") if 
                          @current_page < @page_total
      end

      def link_to_previous
        add_to_template link_to(@previous_label, @base_url + "/page/#{@prev_page}" , :class => "previous") if 
                          @current_page > 1
      end

      def link_to_first
        add_to_template link_to(@first_label, @base_url + "/page/#{'1'}", :class => "first") if 
                          @current_page < @page_total
      end

      def link_to_last
        add_to_template link_to(@last_label, @base_url + "/page/#{@page_total}" , :class => "last") if 
                          @current_page > 1
      end

      def page_out_of_total
        add_to_template "#{@current_page} of #{@page_total}"
      end

      private 
        def add_to_template(string)
          template = "\n\t" + string
          template.html_safe
          string
        end
    end
end

