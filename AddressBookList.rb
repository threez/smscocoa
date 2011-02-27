# AddressBookList.rb
# SMSSend
#
# Created by Vincent Landgraf on 20.02.11.
# Copyright 2011 Vincent Landgraf. All rights reserved.

class ABPerson
  # Pull first and last name, organization, and record flags
  # If the entry is a company, display the organization name instead
  def displayName
    firstName = valueForProperty KABFirstNameProperty
    lastName = valueForProperty KABLastNameProperty
    companyName = valueForProperty KABOrganizationProperty
    flagsValue = valueForProperty KABPersonFlags

    flags = flagsValue ? flagsValue.intValue : 0
    if (flags & KABShowAsMask) == KABShowAsCompany
      return companyName if companyName and companyName.length > 0
    end
    
    lastNameFirst = (flags & KABNameOrderingMask) == KABLastNameFirst
    hasFirstName = firstName and firstName.length > 0
    hasLastName = lastName and lastName.length > 0
  
    if hasLastName and hasFirstName
      if lastNameFirst
        "#{lastName} #{firstname}"
      else
        "#{firstName} #{lastName}"
      end
    elsif hasLastName
      lastName
    elsif hasFirstName
      firstName
    else
      'n/a'
    end
  end
  
end

class ABMultiValue
  def firstValueForLabel(label)
    count.times do |i|
      if labelAtIndex(i) == label
        return valueAtIndex(i)
      end
    end
    return nil
  end
end

class AddressBookList < NSObject
  def comboBox(combobox, objectValueForItemAtIndex:index)
    list[index].first
  end
  
  def numberOfItemsInComboBox(combobox)
    list.size
  end
  
  def findNumber(name)
    found = list.find do |item|
      item.first == name
    end
    found.last if found
  end
  
  def list
    @list ||= begin
      ABAddressBook.sharedAddressBook.people.map do |address|
        if phones = address.valueForProperty(KABPhoneProperty)
          [address.displayName, phones.firstValueForLabel(KABPhoneMobileLabel)]
        end
      # remove empy items or items without mobile number
      end.select do |item| 
        item != nil && item.last != nil
      end.sort do |x, y|
        x.first <=> y.first
      end
    end
  end
end
