module SplitAccounts
  class Split < ActiveRecord::Base

    belongs_to :parent_split_account, class_name: "SplitAccounts::SplitAccount", foreign_key: :parent_split_account_id, inverse_of: :splits
    belongs_to :subaccount, class_name: "Account", foreign_key: :subaccount_id, inverse_of: :parent_splits

    scope :with_extra_penny, -> { where(extra_penny: true) }

    validates :parent_split_account, presence: true
    validates :subaccount, presence: true

    validate :not_self_referential

    def not_self_referential
      if parent_split_account == subaccount
        errors.add(:subaccount, :not_self_referential)
      end
    end

  end
end
