module SecureRooms

  module AccessRules

    class Verdict

      attr_accessor :reason, :result_code

      def initialize(result_code, reason = nil)
        @result_code = result_code
        @reason = reason
      end

      def pass?
        has_result_code?(:pass)
      end

      def denied?
        has_result_code?(:deny)
      end

      def granted?
        has_result_code?(:grant)
      end

      def has_result_code?(code)
        @result_code == code
      end

    end

  end

end
