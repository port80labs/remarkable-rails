module Remarkable
  module ActionController
    module Matchers
      class AssignToMatcher < Remarkable::ActionController::Base #:nodoc:
        arguments :collection => :names, :as => :name, :block => :block

        optional :with, :with_kind_of
        collection_assertions :assigned_value?, :is_kind_of?, :is_equal_value?

        before_assert :evaluate_expected_value

        default_options :with_expectations => true

        protected

          def assigned_value?
            !assigned_value.nil? || value_to_compare?
          end

          def is_kind_of?
            return true unless @options[:with_kind_of]
            return assigned_value.kind_of?(@options[:with_kind_of])
          end

          # Returns true if :with is not given and no block is given.
          # In case :with is a proc or a block is given, we evaluate it in the
          # @spec scope.
          #
          def is_equal_value?
            return true unless value_to_compare?
            assigned_value == @options[:with]
          end

          def assigned_value
            @subject.instance_variable_get("@#{@name}")
          end

          def value_to_compare?
            @options.key?(:with) || @block
          end 

          # Update interpolation options
          def interpolation_options
            { :assign_inspect => assigned_value.inspect, :assign_class => assigned_value.class.name }
          end

          # Evaluate procs before assert to avoid them appearing in descriptions.
          def evaluate_expected_value
            if value_to_compare?
              value = @options[:with] || @block
              value = @spec.instance_eval(&value) if value.is_a?(Proc)
              @options[:with] = value
            end
          end

      end

      # Checks if the controller assigned the variables given by name.
      #
      # == Options
      #
      # * <tt>:with</tt> - The value to compare the assign.
      #   It can be also be supplied as proc or as a block (see examples below)
      #
      # * <tt>:with_kind_of</tt> - The expected class of the assign.
      #
      # == Examples
      #
      #   should_assign_to :user, :with_kind_of => User
      #   should_assign_to :user, :with => proc{ users(:first) }
      #   should_assign_to(:user){ users(:first) }
      #
      #   it { should assign_to(:user) }
      #   it { should assign_to(:user, :with => users(:first)) }
      #   it { should assign_to(:user, :with_kind_of => User) }
      #
      def assign_to(*args, &block)
        AssignToMatcher.new(*args, &block).spec(self)
      end

    end
  end
end
