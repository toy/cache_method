module CacheMethod
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def cache_method(*names)
      names.each do |name|
        class_eval <<-src_code, __FILE__, __LINE__
          alias_method("calculate_#{name}", name)
          def #{name}
            read_attribute(#{name.inspect}) || update_#{name}
          end
          def update_#{name}
            store_#{name}(calculate_#{name})
          end
          def store_#{name}(value)
            write_attribute(#{name.inspect}, value)
            save unless new_record?
            value
          end
          def reset_#{name}
            store_#{name}(nil)
          end
        src_code
      end
    end
  end
end
