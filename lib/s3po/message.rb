module MosEisley
  module S3PO
    class Message
      attr_reader :event

      def initialize(e)
        @event = e
      end

      def message_type
        return nil if event[:channel].nil?
        t = :na
        case event[:channel][0]
        when 'C'
          t = :channel
        when 'D'
          t = :im
        when 'G'
          t = :group
        end
        return t
      end

      def simple_message?
        event[:subtype].nil?
      end

      def for_me?
        # check user is not myself
        myid = MosEisley.config.meta[:user_id]
        return false if event[:user] == myid
        return true if message_type == :im && simple_message?
        return true if (event[:text] =~ /^<@#{myid}[|>]/) && simple_message?
        return false
      end

      def text
        event[:text]
      end

      # Defines text; existing string will be overwritten
      # @param t [String] text to assign
      def text=(t)
        event[:text] = t
      end

      # Adds text after a space if text already exists
      # @param t [String] text to add
      def add_text(t)
        nt = [event[:text], t].compact.join(' ')
        event[:text] = nt[0].upcase + nt[1..-1]
      end

      def attachments
        event[:attachments]
      end

      def attachments=(a)
        event[:attachments] = a
      end

      def user
        event[:user]
      end

      def user=(u)
        event[:user] = u
      end

      def ts
        event[:ts]
      end

      def channel
        event[:channel]
      end

      def thread_ts
        event[:thread_ts]
      end

      def arguments
        return nil unless simple_message?
        t = event[:text]
        t = t.sub(/^<@#{MosEisley.config.meta[:user_id]}[|]?[^>]*>/, '') if for_me?
        t.split
      end

      def postable_object
        obj = @event.dup
        return obj unless obj[:attachments]
        obj[:attachments] = S3PO.json_with_object(obj[:attachments])
        return obj
      end

      # Create a new Message object for replying; pre-fills some attributes
      # @param t [String] thread timestamp; only when replying as a thread (better to call #reply_in_thread instead)
      # @return [MosEisley::S3PO::Message]
      def reply(t = nil)
        s = {
          channel: channel,
          as_user: true,
          attachments: []
        }
        s[:text] = "<@#{user}>" unless message_type == :im
        if thread_ts
          s[:thread_ts] = thread_ts
        elsif t
          s[:thread_ts] = t
        end
        Message.new(s)
      end

      def reply_in_thread
        t = thread_ts
        t ||= ts
        reply(t)
      end
    end
  end
end
