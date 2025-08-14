module Errors
  class PendingApprovalError < Pundit::NotAuthorizedError
    def message
      "Your account is waiting for admin approval to use this function."
    end
  end
end