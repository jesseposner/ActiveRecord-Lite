require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: "#{name.to_s.underscore}_id".to_sym,
      primary_key: :id,
      class_name: "#{name.to_s.camelcase.singularize}"
    }
    defaults_with_options = defaults.merge(options)
    @foreign_key = defaults_with_options[:foreign_key]
    @primary_key = defaults_with_options[:primary_key]
    @class_name = defaults_with_options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      foreign_key: "#{self_class_name.to_s.underscore}_id".to_sym,
      primary_key: :id,
      class_name: "#{name.to_s.camelcase.singularize}"
    }
    defaults_with_options = defaults.merge(options)
    @foreign_key = defaults_with_options[:foreign_key]
    @primary_key = defaults_with_options[:primary_key]
    @class_name = defaults_with_options[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    defaults_with_options = BelongsToOptions.new(name, options)
    define_method(name) do
      key = self.send(defaults_with_options.foreign_key)
      model_class = defaults_with_options.model_class
      model_class.where(id: key).first
    end
  end

  def has_many(name, options = {})
    defaults_with_options = HasManyOptions.new(name, self, options)
    define_method(name) do
      primary_key = self.send(defaults_with_options.primary_key)
      model_class = defaults_with_options.model_class
      model_class.where(defaults_with_options.foreign_key => primary_key)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Searchable
  extend Associatable
end
