require "yast"

module UI
  # Provides switch between event_loop and dispatching to handlers.
  # @example simple OK/cancel dialog
  #   class OKDialog
  #     include Yast::UIShortcuts
  #     include Yast::Logger
  #     include UI::EventDispatcher
  #     Yast.import "UI"
  #
  #     def run
  #       return nil unless Yast::UI.OpenDialog(
  #         HBox(
  #           PushButton(Id(:ok), "OK"),
  #           PushButton(Id(:cancel), "Cancel")
  #         )
  #       )
  #       begin
  #         return event_loop
  #       ensure
  #          Yast::UI.CloseDialog
  #       end
  #     end
  #
  #     def ok_handler
  #       finish_dialog(:ok)
  #       log.info "OK button pressed"
  #     end
  #   end
  module EventDispatcher
    # Does UI event dispatching.
    # @return value from exit_dialog method.
    def event_loop
      Yast.import "UI"
      @_finish_dialog_flag = false

      loop do
        input = user_input
        if respond_to?(:"#{input}_handler")
          send(:"#{input}_handler")
          return @_finish_dialog_value if @_finish_dialog_flag
        else
          raise "Unknown action #{input}"
        end
      end
    end

    # Reads input for next event dispath
    # Can be redefined to modify the way of getting user input, like introducing a timeout.
    # Default implementation uses Yast::UI.UserInput which waits indefinitely for user input.
    # @example use user input with timeout
    #    class OKDialog
    #     include Yast::UIShortcuts
    #     include Yast::Logger
    #     include UI::EventDispatcher
    #     Yast.import "UI"
    #
    #     def user_input
    #       Yast::UI.TimeoutUserInput(1000)
    #     end
    #
    #     def run
    #       return nil unless Yast::UI.OpenDialog(
    #         HBox(
    #           PushButton(Id(:ok), "OK"),
    #           PushButton(Id(:cancel), "Cancel")
    #         )
    #       )
    #       begin
    #         return event_loop
    #       ensure
    #          Yast::UI.CloseDialog
    #       end
    #     end
    #
    #     def ok_handler
    #       finish_dialog(:ok)
    #       log.info "OK button pressed"
    #     end
    #   end

    def user_input
      Yast::UI.UserInput
    end

    # Set internal flag to not continue with processing other UI inputs
    # @param return_value[Object] value to return from event_loop
    def finish_dialog(return_value = nil)
      @_finish_dialog_flag = true
      @_finish_dialog_value = return_value
    end

    # Default handler for cancel which can be also 'x' on dialog window
    def cancel_handler
      finish_dialog
    end
  end
end
