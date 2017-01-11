module ApplicationHelper
	def fullname(fname,lname)
	  "#{fname}" + " #{lname}"
	end

  def add_limit type, amount
    if type == 'add'
      return amount
    else
      return 0
    end
  end

  def less_limit type, amount
    if type == 'less'
      return amount
    else
      return 0
    end
  end

  def distributor_detail distributor
  	name = fullname(distributor.try(:profile).try(:first_name), distributor.try(:profile).try(:last_name))
  	"#{name} \n #{distributor.try(:user).try(:mobile)}"
  end

  def format_date date
    date.in_time_zone.strftime("%d-%m-%y at %I:%M%p")
  end

  def status_date create, update
    if create == update
      ''
    else
      update.in_time_zone.strftime("%d-%m-%y at %I:%M%p")
    end
  end

  def sender_detail sender
    "#{sender.try(:name)} " + "#{sender.try(:mobile)} " + "#{sender.try(:address)}"
  end

  def bank_details bank
    "#{bank.try(:branch)} " +"#{bank.try(:city)} " + "#{bank.try(:state)}"
  end

  def merchant_details merchant
    "#{merchant.try(:profile).try(:first_name)} "+"#{merchant.try(:profile).try(:last_name)} " + "#{merchant.try(:user).try(:mobile)} "
  end

  def distributor_details distributor
    "#{distributor.try(:profile).try(:first_name)} "+"#{distributor.try(:profile).try(:last_name)} " + "#{distributor.try(:user).try(:mobile)} "
  end

  def transaction_type type
    if type
      'Quick'
    else
      'Normal'
    end
  end

  def quick_check value
    if value.quick_request
     'QUICK'
    else
      'NORMAL'
    end
  end

  def quick_transfer value
    if value.quick_transfer
     'QUICK'
    else
      'NORMAL'
    end
  end

end
