require_relative 'searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    Object.const_get(class_name.to_s)
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || "#{name}".singularize.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore.downcase}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || "#{name}".singularize.camelcase
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method("#{name}") do
      f_key = send(options.foreign_key)
      options.model_class.where(:id => f_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, "#{self}", options)
    define_method("#{name}") do
      # value = send(options.primary_key)
      # target_class = options.model_class
      # target_class.where(options.foreign_key => value)

      # f_key = send(options.foreign_key)
      f_key = options.foreign_key
      p_key = send(options.primary_key)
      options.class_name.where(f_key => self.id)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
  define_method(name) do
    through_opts = self.class.assoc_options[through_name]
    source_opts = through_opts.model_class.assoc_options[source_name]
    f_key = self.send(through_opts.foreign_key)
    data = DBConnection.execute(<<-SQL, f_key)
      SELECT
        #{source_opts.table_name}.*
      FROM
        #{through_opts.table_name}
      INNER JOIN
        #{source_opts.table_name}
      ON #{source_opts.foreign_key} = #{source_opts.table_name}.#{source_opts.primary_key}
      WHERE
        #{through_opts.table_name}.#{through_opts.primary_key} = ?
    SQL
    data.empty? ? nil : source_opts.model_class.new(data.first)
  end
end
end

class SQLObject
  extend Associatable
end
