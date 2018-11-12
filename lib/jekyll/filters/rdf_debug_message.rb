module Jekyll

  module JekyllRdf

    ##
    # Internal module to hold the medthod #rdf_message
    #
    module Filter
      def rdf_debug_message(message, logLevel = "info") #:nodoc:
        case logLevel
        when "info"
          Jekyll.logger.info message
        when "warn"
          Jekyll.logger.warn message
        when "error"
          Jekyll.logger.error message
        when "debug"
          Jekyll.logger.debug message
        else
          Jekyll.logger.info "NoLevel: #{message}"
        end
      end
    end
  end
end
