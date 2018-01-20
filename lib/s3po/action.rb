module MosEisley
  module S3PO
    class Action
      attr_reader :event
      attr_reader :original_message

      def initialize(e)
        @event = e
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

      def attachment_id
        event[:attachment_id].to_i
      end

      def response_url
        event[:response_url]
      end

      def message_age
        Time.now.to_i - message_ts.to_i
      end
    end
  end
end
