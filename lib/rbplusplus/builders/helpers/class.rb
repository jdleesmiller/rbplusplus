module RbPlusPlus
  module Builders
    module ClassHelpers

      # Build up any classes under this module
      def with_classes
        self.code.classes.each do |klass|
          next if do_not_wrap?(klass)
          add_child ClassNode.new(klass, self)
        end
      end

      # Wrap any constructors for this class
      def with_constructors
        self.code.constructors.find(:access => :public).each do |constructor|
          next if do_not_wrap?(constructor)

          # Ignore the generated copy constructor
          next if constructor.attributes[:artificial] && constructor.arguments.length == 1

          add_child ConstructorNode.new(constructor, self)
        end
      end

      # Wrap up any class constants
      def with_constants
        self.code.constants.find(:access => :public).each do |const|
          next if do_not_wrap?(const)
          add_child ConstNode.new(const, self)
        end
      end

      # Expose the public variables for this class
      def with_variables
      end

      # Wrap up all public methods
      def with_methods
        self.code.methods.find(:access => :public).each do |method|
          next if do_not_wrap?(method)

          if method.static?
            add_child StaticMethodNode.new(method, self)
          else
            add_child MethodNode.new(method, self)
          end
        end
      end

    end
  end
end
