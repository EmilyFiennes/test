class Action
  attr_reader :who, :amount

  def initialize(who, amount)
    @who = who
    @amount = amount
  end

  def type
    amount > 0 ? 'credit' : 'debit'
  end

  def serialize
    { "who" => who, "type" => type, "amount" => amount.abs.round }
  end
end
