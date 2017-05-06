class ExportData
  attr_reader :extension

  def initialize(data, extension)
    @data = data
    @extension = extension
  end

  def read
    @data
  end
end
