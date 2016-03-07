# coding: utf-8
# general use for all models
module Mongoid
  module BaseModel
    extend ActiveSupport::Concern
    included do
      include Mongoid::Document
      include Mongoid::Timestamps

      scope :recent, desc(:updated_at)
      scope :exclude_ids, Proc.new { |ids| where(:_id.nin => ids.map(&:to_i)) }
      scope :by_week, where(:created_at.gte => 7.days.ago.utc)

      delegate :url_helpers, to: 'Rails.application.routes'

      before_save :stop_redundent_save
      def stop_redundent_save
        return false if not self.changed?
      end
    end

    module ClassMethods
      # like ActiveRecord find_by_id
      def find_by_id(id)
        if id.is_a?(Integer) or id.is_a?(String)
          where(:_id => id.to_i).first
        else
          nil
        end
      end

      def find_in_batches(opts = {})
        batch_size = opts[:batch_size] || 1000
        start = opts.delete(:start).to_i || 0
        objects = self.limit(batch_size).skip(start)
        t = Time.new
        while objects.any?
          yield objects
          start += batch_size
          # Rails.logger.debug("processed #{start} records in #{Time.new - t} seconds") if Rails.logger.debug?
          break if objects.size < batch_size
          objects = self.limit(batch_size).skip(start)
        end
      end

      def delay
        Sidekiq::Extensions::Proxy.new(DelayedDocument, self)
      end
    end

    def delay
      Sidekiq::Extensions::Proxy.new(DelayedDocument, self)
    end
  
    def slug_sanitize
      self.slug = slug_process(self.slug)
      #self.slug = Pinyin.t(self.slug, '_').gsub(/[^\w]/, "_").downcase.gsub(/__*/, '_')[0..127]
    end

    def slug_process(slug)
      slug = Pinyin.t(slug, '_').gsub(/[^\w]/, "_").downcase.gsub(/__*/, '_')[0..127]
    end

  end
end

