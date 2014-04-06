class Object
  module Aliaser
    # When included into modules, this will allow classes to rename functions
    # but only for the files that include the renamed class.
    def self.included(m)
      super

      m.send(:extend, ClassMethods)
    end

    module ClassMethods
      # Define the 'tag' such as :engUS, :spaES, etc
      # When one does a 'require' it will require the interface from a subdir
      # for that tag.
      def define(tag)
        @@__name_sets ||= {}
        @@__name_sets[:original] ||= {}

        @@__name_sets[tag] = {}

        @@__defining = tag
      end

      # Renames a method for the current tag
      def rename(a, b)
        @@__name_sets[@@__defining][b] = :"__#{a}"
        @@__name_sets[:original][a] = :"__#{a}"

        class<<self
          self
        end.class_eval do
          alias_method :"__#{a}", a
          remove_method a
        end
      end

      # Handle 'respond_to' for the current tag
      def respond_to?(m, *args)
        set_name = Kernel.__set

        names = @@__name_sets[set_name]
        if names
          f = names[m]
          if f
            return true
          end
        end

        super(m, *args)
      end

      # Call the correct method for the current tag
      def method_missing(m, *args)
        set_name = Kernel.__set

        names = @@__name_sets[set_name]

        if names
          f = names[m]
          if f
            return send(f, *args)
          end
        end

        super(m, *args)
      end
    end
  end
end

# When a class we know about is loaded, note the calling
# source file and note which name set it wants to use
module Kernel
  alias_method :__require, :require
  alias_method :__require_relative, :require_relative

  # Get the current tag
  def __set()
    caller.each do |c|
      source = c[/^([^:]+):/,1]
      set = @@__sets[source]
      return set if set
    end

    :original
  end

  # When we require, we can select a tag by passing a symbol:
  #   require :engUS
  # Which means all subsequent requires for THIS module will
  # require from INCLUDE_PATH/engUS/*
  # When we require a file, the default tag for that file is
  # applied as :original which means it may require files from
  # the base INCLUDE_PATH
  def require(file, *args)
    source = caller[0][/^([^:]+):/,1]
    @@__sets ||= {}
    if file.is_a? Symbol
      set_name = file

      @@__sets[source] = set_name
    else
      set_name = @@__sets[source]

      if set_name
        begin
          return __require(File.join(set_name.to_s, file))
        rescue
        end
      else
        $:.each do |p|
          path = File.join(p, file)
          if File.exists? path
            file = path
            break
          end
        end

        @@__sets[file] = :original
      end

      __require(file, *args)
    end
  end

  # Require_relative does the same as require except also searches the base path of the
  # caller.
  def require_relative(file, *args)
    paths = $:
    paths.push(File.realpath(File.absolute_path(File.dirname(caller[0][/^([^:]+)/,1]))))

    paths.each do |p|
      path = File.join(p, file)
      path = "#{path}.rb" unless path.end_with? ".rb"
      if File.exists?(path) || File.exists?(path + ".rb")
        file = File.realpath(path)
        break
      end
    end

    @@__sets[file] = :original

    __require_relative(file, *args)
  end
end
