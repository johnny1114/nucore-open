require "rails_helper"

RSpec.describe SecureRooms::AccessHandlers::EventHandler, type: :service do
  let(:user) { create :user }
  let(:card_reader) { create :card_reader }

  describe "#process" do
    context "with access denial verdict" do
      let(:verdict) do
        SecureRooms::AccessRules::Verdict.new(:deny, :no_accounts, user, card_reader)
      end

      it "creates an Event" do
        expect { described_class.process(verdict) }
          .to change(SecureRooms::Event, :count).by(1)
      end

      describe "resulting Event" do
        subject(:event) { described_class.process(verdict) }

        it "stores the user and reader" do
          expect(event.card_reader).to eq card_reader
          expect(event.user).to eq user
        end
      end
    end

    context "with access granted verdict" do
      let(:accounts) { create_list(:account, 3, :with_account_owner, owner: user) }
      let(:selected_account) { accounts.first }

      let(:verdict) do
        SecureRooms::AccessRules::Verdict.new(
          :grant,
          :selected_account,
          user,
          card_reader,
          accounts: accounts,
          selected_account: selected_account,
        )
      end

      describe "resulting Event" do
        subject(:event) { described_class.process(verdict) }

        it "stores the account used" do
          expect(event.account).to eq selected_account
        end
      end
    end
  end
end
