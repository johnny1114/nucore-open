module SplitAccounts
  class SplitAccount < Account

    has_many :splits, class_name: "SplitAccounts::Split", foreign_key: :parent_split_account_id, inverse_of: :parent_split_account
    has_many :subaccounts, through: :splits

    validate :valid_percent_total
    validate :one_split_has_extra_penny
    validate :unique_split_subaccounts
    validate :more_than_one_split

    accepts_nested_attributes_for :splits, allow_destroy: true

    before_save :set_expires_at_from_subaccounts
    before_save :set_suspended_at_from_subaccounts

    def valid_percent_total
      if percent_total != 100
        errors.add(:splits, :percent_total)
      end
    end

    def percent_total
      splits.reduce(0) do |sum, split|
        split.percent.present? ? sum + split.percent : sum
      end
    end

    def one_split_has_extra_penny
      if extra_penny_count != 1
        errors.add(:splits, :only_one_extra_penny)
      end
    end

    def unique_split_subaccounts
      if duplicate_subaccounts?
        errors.add(:splits, :duplicate_subaccounts)
      end
    end

    def extra_penny_count
      splits.select(&:extra_penny?).size
    end

    def duplicate_subaccounts?
      splits.map(&:subaccount_id)
        .group_by { |subaccount_id| subaccount_id }
        .reject { |key, value| key.blank? }
        .any? { |key, value| value.size > 1 }
    end

    def more_than_one_split
      if splits.size <= 1
        errors.add(:splits, :more_than_one_split)
      end
    end

    # Stopped using SQL because that didn't work until the built splits
    # and subaccounts were persisted. And `subaccounts` has_many :through seems
    # to not work here either.
    def earliest_expiring_subaccount
      subaccounts = splits.map(&:subaccount).compact.select(&:expires_at?)
      subaccounts.min_by(&:expires_at)
    end

    def earliest_suspended_subaccount
      subaccounts = splits.map(&:subaccount).compact.select(&:suspended_at?)
      subaccounts.min_by(&:suspended_at)
    end

    # Updates the parent account expires_at with earliest subaccount expires_at.
    # Gracefully handles whenever all subaccounts have expires_at set to nil
    # (even though techincally expires_at should always be set).
    def set_expires_at_from_subaccounts
      self.expires_at = earliest_expiring_subaccount.try(:expires_at)
    end

    # Suspend the parent account if any subaccounts are suspended.
    # Do not automatically unsuspend the parent account if all subaccounts
    # become unsuspended.
    def set_suspended_at_from_subaccounts
      subaccount = earliest_suspended_subaccount
      self.suspended_at = subaccount.suspended_at if subaccount
    end

    def recreate_journal_rows_on_order_detail_update?
      true
    end

    def recreate_journal_rows_on_order_detail_update?
      true
    end

  end
end
