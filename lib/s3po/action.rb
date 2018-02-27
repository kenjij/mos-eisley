module MosEisley
  module S3PO
    class Action
      attr_reader :event, :type, :original_message

      def self.add_pending(act)
        pending_gc
        @pending ||= {}
        @pending[act.callback_id] = act
      end

      def self.pending
        pending_gc
        @pending
      end

      def self.pending_gc
        return unless @pending
        return if @gc_running
        @gc_running = true
        delkeys = []
        @pending.each do |id, act|
          ts = Time.at(act.action_ts.to_f)
          delkeys << id if Time.now - ts > 60 * 30
        end
        delkeys.each { |k| @pending.delete(k) }
        @gc_running = false
      end

      def initialize(e)
        @event = e
        @type = @event[:type].to_sym
        if e[:original_message]
          @original_message = Message.new(e[:original_message])
        end
      end

      def action
        event[:actions][0]
      end

      def callback_id
        event[:callback_id]
      end

      def channel
        event[:channel][:id]
      end

      def user
        event[:user][:id]
      end

      def message_ts
        event[:message_ts]
      end

      def action_ts
        event[:action_ts]
      end

      def attachment_id
        event[:attachment_id].to_i
      end

      def response_url
        event[:response_url]
      end

      def trigger_id
        event[:trigger_id]
      end

      def submission
        event[:submission]
      end

      def original_event
        Action.pending[callback_id]
      end

      def message_age
        Time.now.to_i - message_ts.to_i
      end
    end
  end
end
