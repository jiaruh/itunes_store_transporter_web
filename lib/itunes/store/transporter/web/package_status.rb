module ITunes
  module Store
    module Transporter
      module Web
        class PackageStatus
          APPROVED = "Approved".freeze
          IN_REVIEW = "In Review".freeze

          REVIEW = "Review".freeze
          NOT_ON_STORE = "Not on Store".freeze
          READY = "Ready".freeze
          ON_STORE = "On Store".freeze

          def initialize(status)
            @status = status || {}
          end

          def to_s
            case
            when review?
              REVIEW
            when not_on_store?
              NOT_ON_STORE
            when ready?
              READY
            when on_store?
              ON_STORE
            when @status[:info]
              # Is this correct? Ask P9
              @status[:info].first[:status]
            end
          end

          alias :inspect :to_s

          private

          def content_status
            @content_status ||= @status[:content_status] || {}
          end

          def video_components
            @video_components ||= content_status[:video_components] || []
          end

          def store_status
            return @store_status if defined?(@store_status)
            @store_status = content_status[:store_status] || {}
            @store_status.default = []
            @store_status
          end

          def review?
            store_status[:not_on_store].any? &&
              video_components.any? &&
              video_components.all? { |vc| vc[:status] == "In Review" }
          end

          def not_on_store?
            store_status[:not_on_store].any? ||
              video_components.any? { |vc| vc[:status] != "Approved" }
          end

          def ready?
            store_status[:not_on_store].none? &&
              store_status[:on_store].none? &&
              store_status[:ready_for_store].any? &&
              video_components.all? { |vc| vc[:status] == "Approved" }
          end

          def on_store?
            store_status[:not_on_store].none? &&
              store_status[:ready_for_store].none? &&
              store_status[:on_store].any? &&
              video_components.all? { |vc| vc[:status] == "Approved" }
          end

        end
      end
    end
  end
end