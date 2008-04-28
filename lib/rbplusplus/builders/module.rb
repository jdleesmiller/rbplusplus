module RbPlusPlus
  module Builders

    # This class handles generating source for a requested Module
    class ModuleBuilder < Base

      # Initializer takes the parent object and the RbModule construction
      def initialize(parent, mod)
        super(mod.name, mod.node)
        @module = mod
        self.parent = parent
      end

      def build
        # Using qualified name with underscores here to allow for nested modules
        # of the same name
        self.rice_variable = "rb_m#{self.qualified_name.gsub(/::/, "_")}"
        self.rice_variable_type = "Rice::Module"

        includes << "#include <rice/Module.hpp>"

        mod_defn = "\t#{rice_variable_type} #{rice_variable} = "
        if !parent.is_a?(ExtensionBuilder)
          mod_defn += "Rice::define_module_under(#{parent.rice_variable}, \"#{name}\");"
        else
          mod_defn += "Rice::define_module(\"#{name}\");"
        end

        body << mod_defn

        # If a namespace has been given to this module, find and wrap the appropriate code
        if @node
          build_functions
          build_classes
        end

        # Build each inner module
        @module.modules.each do |mod|
          builder = ModuleBuilder.new(self, mod)
          builder.build
          builders << builder
        end
      end

      # Process functions to be added to this module
      def build_functions
        @node.functions.each do |func|
          includes << "#include \"#{func.file_name(false)}\""

          func_name = Inflector.underscore(func.name)
          body << "\t#{self.rice_variable}.define_module_function(\"#{func_name}\", &#{func.qualified_name});"
        end
      end

      # Special name handling. Qualified name is simply the name of this module
      def qualified_name
        if parent.is_a?(ModuleBuilder)
          "#{parent.qualified_name}::#{self.name}"
        else
          self.name
        end
      end

    end
  end
end