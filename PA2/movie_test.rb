class MovieTest
  #MovieTest holds prediction/test data and basic statistical operations
  #It has methods to calculate mean error, stddev of error, and rms of error
  def initialize
    @predictions = []
  end

  def add_prediction(u, m, r, p)
    #Adds a row of data to our internal array
    @predictions.push([u, m, r, p])
  end

  def mean
    #Calculate the mean of the error
    sum = 0.0
    count = 0.0
    @predictions.each do |array|
      sum += (array[2] - array[3]).abs
      count += 1
    end

    return sum/count
  end

  def stddev
    #Calculate standard deviation of error
    mean_error = mean()
    sum = 0.0
    @predictions.each do |array|
      error = (array[2] - array[3]).abs
      sum += (error - mean_error)**2
    end
    variance = sum / (@predictions.length - 1)
    return variance ** 0.5
  end

  def rms
    #Calculate root mean square of error
    sum = 0.0
    @predictions.each do |array|
      sum += (array[2] - array[3])**2
    end
    variance = sum / @predictions.length
    return variance ** 0.5

  end

  def to_a
    #Return the predictions / test data, which is just our internal array
    return @predictions
  end
end
