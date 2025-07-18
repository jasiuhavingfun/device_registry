# frozen_string_literal: true

module AssigningError
  class AlreadyUsedOnUser < StandardError; end
  class AlreadyUsedOnOtherUser < StandardError; end
end
