# SmsController.rb
# SMSSend
#
# Created by Vincent Landgraf on 19.02.11.
# Copyright 2011 Vincent Landgraf. All rights reserved.
require "smspromote"

class SmsController < NSObject
  MESSAGE_SIZE = 160
  
  ERROR_MESSAGES = {
    -1  => "Anwendungsfehler",
    0   => "Keine Verbindung zum Gateway",
    10  => "Empfänger fehlerhaft",
    20  => "Absenderkennung zu lang",
    30  => "Nachrichtentext zu lang",
    31  => "Messagetyp nicht korrekt",
    40  => "Falscher SMS-Typ",
    50  => "Fehler bei Login",
    60  => "Guthaben zu gering",
    70  => "Netz wird von Route nicht unterstützt",
    71  => "Feature nicht über diese Route möglich",
    80  => "SMS konnte nicht versendet werden",
    90  => "Versand nicht möglich",
    100 => "SMS wurde erfolgreich versendet."
  }

  attr_writer :creditLabel, :receiverField, :sendButton, :contentField
  attr_writer :goldRouteCheckbox, :counterField, :addressBookList, :parentWindow
  
  def sendSms(sender)
    # display message if not all fields are filled out correctly
    if currentPhone == nil || currentText.empty?
      showMessage "Empfänger oder Text ist leer!",
                  "Bitte Empfänger oder SMS Text eintragen..."
    elsif gateway = currentGateway
      msg = SmsPromote::Message.new(currentPhone, currentText)
      puts "[Gateway] send sms..."
      gateway.send_message(msg)
      p msg
      
      showMessage("Sende Nachright an #{receiver} " \
                  "(MessageID: #{msg.message_id || "-"} Cost: #{msg.cost || "-"})",
                  ERROR_MESSAGES[msg.code || -1])
      
      refreshCredit(self)
    else
      showMessage "Kann Gateway nicht erstellen",
                  "Gatewaykonfiguration prüfen..."
    end
  end
  
  # returns the current text as gsm encoded byte string
  def currentText
    String.new(@contentField.stringValue || "").encode("ISO-8859-1")
  end
  
  # will be called when content area changes and update the counter field
  def controlTextDidChange(notification)
    left, count = calcSmsSize(currentText)
    @counterField.setStringValue("#{left}/#{count}")
  end
  
  # returns the phone number of the current selected reciever
  def currentPhone
    String.new(@addressBookList.findNumber(receiver) || "").encode("ISO-8859-1")
  end
  
  # returns the name of the receiver
  def receiver
    @receiverField.stringValue
  end
  
  # returns true if the gold routing (gateway) should be used
  def goldRoute?
    @goldRouteCheckbox.state == NSOnState
  end
  
  # returns the gateway to use
  def currentGateway
    if Configuration.exists?
      # read config
      key = Configuration.valueForKey :api_key
      originator = Configuration.valueForKey :originator
    
      # create gateways
      if goldRoute? 
        SmsPromote::Gateway.new(key, :secure => true, :originator => originator)
      else
        SmsPromote::Gateway.new(key, :secure => true)
      end
    else
      false
    end
  end
  
  # refreshes the label with the current credit
  def refreshCredit(sender)
    if gateway = currentGateway
      puts "[Gateway] load credit information..."
      @creditLabel.setDoubleValue(gateway.credits)
    end
  end
  
  # initialize the controller and view 
  def applicationDidFinishLaunching(notification)
    if Configuration.exists?
      # show initial credits
      refreshCredit(self)
    else
      # open the configuration editor
      showConfiguration
    end
  end
  
  # returns array with left chars and number of messages
  def calcSmsSize(text)
    chars = text.bytesize
    messages = (chars - chars % MESSAGE_SIZE) / MESSAGE_SIZE
    chars = chars - messages * MESSAGE_SIZE
    [MESSAGE_SIZE - chars, messages]
  end
  
  # shows a modal message for the use with an ok button
  def showMessage(title, msg)
    alert = NSAlert.alertWithMessageText title,
                                         defaultButton: "OK",
                                         alternateButton: nil,
                                         otherButton: nil,
                                         informativeTextWithFormat: msg
    alert.beginSheetModalForWindow @parentWindow, 
                                   modalDelegate: nil,
                                   didEndSelector: nil,
                                   contextInfo: nil
  end
  
  # shows the configuration file of sms send
  def showConfiguration
    puts "create config file using template"
    Configuration.create_file
    system "open #{Configuration.file_path}"
  end
end
