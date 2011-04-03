require "yaml"
require "fileutils"

module Configuration
  FOLDER = ".smssend"
  FILE = "config.yml"
  
  # returns true if the configuratio file exists
  def self.exists?
    File.exist? file_path
  end
  
  # returns the path to the folder
  def self.folder_path
    File.join(ENV["HOME"], FOLDER)
  end
  
  # returns the path to the config file
  def self.file_path
    File.join(folder_path, FILE)
  end

  # returns the value for the configuration option
  def self.valueForKey(name)
    YAML.load(File.read(file_path))[name]
  end
  
  # creates a config file based on the template
  def self.create_file
    # create folder if it doesn't exist
    FileUtils.mkdir_p folder_path unless File.exist? folder_path
    
    File.open(file_path, "w") do |f|
      f.write template.to_yaml
    end
  end
  
  # template for the config file (at creation)
  def self.template
    {
      :api_key => "your api key here",
      :originator => "0049**********"
    }
  end
end
