	module ActiveRecordFields
		extend ActiveSupport::Concern


		def active_record_fields
			self.class._active_record_fields
		end

		included do
			attributes :active_record_fields
			class_attribute :_active_record_fields
			self._active_record_fields ||= []
		end

		module ClassMethods

			def inherited(base)
      	super
        base._active_record_fields = _active_record_fields.dup
			end

			def has_one(name, options = {}, &block)
				super
				self._active_record_fields.push(name.to_s)
			end

			def has_many(name, options = {}, &block)
				super
				self._active_record_fields.push(name.to_s)
			end

			def belongs_to(name, options = {}, &block)
				super
				self._active_record_fields.push(name.to_s)
			end
		end

	end


class ApplicationSerializer < ActiveModel::Serializer
	include ActiveRecordFields

	attributes :table_name, :active_record_object, :id

	def table_name
		object.class.table_name
	end

	def active_record_object
		true
	end

end