class MovieData
  #Movie data class holds data about training and test sets for movie ratings
  def initialize(directory, prefix_set = nil)
    #Initializing a movie data object requires the directory of where the data is
    #It is optional, but preferred to indicate the training / test pair as well as a symbol

    #Do some housekeeping to load in files into hashmaps
    if prefix_set == nil
      bases = load_data(directory + "//" + "u.data")
      tests = [nil, nil]
    else
      bases = load_data(directory + "//" + prefix_set.to_s + ".base")
      tests = load_data(directory + "//" + prefix_set.to_s + ".test")
    end
    #Define our four hash maps that were retrieved from loading the base and test sets
    @user_rated = bases[0]
    @movies_ratedby = bases[1]
    @user_rated_test = tests[0]
    @movies_ratedby_test = tests[1]
  end

  def load_data(f)
    #Make two hashes, where the first one maps user -> list of (movie_id, user_rating) tuples
    #Second hash maps movie_id -> (list of user_ids who rated it, movie popularity) tuple
    #The reason why the second hash has the list of users who rated it is because I believe it might be useful for Part2
    user_rated = Hash.new
    movies_ratedby = Hash.new

    for line in File.open(f, "r").readlines()
      #Split row into array from whitespace
      row_array = line.split()
      user_id = row_array[0].to_i
      movie_id = row_array[1].to_i
      user_rating = row_array[2].to_i
      #If movie_id does not have user who rated it, create initial map value of (ratedby = [user_id], popularity = user_rating)
      if movies_ratedby[movie_id] == nil
        movies_ratedby[movie_id] = [[user_id, user_rating]]
      else
        movies_ratedby[movie_id].push([user_id, user_rating])
      end
      if user_rated[user_id] == nil
        user_rated[user_id] = [[movie_id, user_rating]]
      else
        user_rated[user_id].push([movie_id, user_rating])
      end
    end
    return [user_rated, movies_ratedby]
  end

  def similarity(user1, user2)
    #This method compares the similarity of two users and outputs an integer (the higher the value the more similar they are)
    #Out similarity metric is basically a sum of how similar their ratings are for movies they both rated
    user1_rated = @user_rated[user1]
    user2_rated = @user_rated[user2]
    similarity_sum = 0

    #We then construct a hash map out of the movies user 2 rated
    #This allows us to match up movie ids in constant time, instead of linear
    user2_map = Hash.new
    user2_rated.each do |movie_id, rating|
      user2_map[movie_id] = rating
    end

    user1_rated.each do |movie_id, rating|
      #If movie ids match up (meaning both users liked the same movie), then do comparison
      #Our comparison metric is 4 - abs(user1 rating - user2 rating), which is added to similarity sum
      user2_rating = user2_map[movie_id]
      if user2_rating != nil
        difference_in_rating = rating - user2_rating
        similarity_sum = similarity_sum + (4 - difference_in_rating.abs)
      end
    end
    return similarity_sum
  end

  def extract_ids(id, hash_map)
    #This method extracts id numbers from hash maps that use 2d arrays
    #This method is used for the movies and viewers methods
    array = hash_map[id]
    ids = Array.new
    array.each do |id, rating|
      ids.push(id)
    end
    return ids
  end


  def movies(u)
    #This method returns an array of what movies user u has watched
    return extract_ids(u, @user_rated)
  end

  def viewers(m)
    #This method returns an array of whats uers have watched movie m
    return extract_ids(m, @movies_ratedby)
  end

  def predict(u, m)
    #The prediction algorithm uses the values of what other users rated the movie
    #We use the similarity algorithm from part 1 of the assignment
    #Basically, we average the ratings of all the users, but we assignment more "weight" to similar users
    #This is done by multiplying our "ratings sum" by the similarity^2, and also keeping a sum of the similarities^2

    users_who_rated = @movies_ratedby[m]
    similarity_total = 0.0
    ratings_total = 0.0

    if users_who_rated == nil
      return 0
    end

    users_who_rated.each do |user_id, rating|
      similarity_val = similarity(u, user_id)
      #The similarity value is squared, this is to give more "weight" to similar users
      ratings_total += (similarity_val ** 2) *rating
      similarity_total += (similarity_val ** 2)
    end

    if similarity_total != 0.0
      return ratings_total/similarity_total
    else
      return 0
    end
  end

  def rating(u, m)
    movie_ratings = @user_rated[u]
    movie_ratings.each do |movie_id, rating|
      return rating if movie_id == m
    end
    return 0
  end

  def run_test(k = -1)
    #Run_test evaluates our predictions for the first k records
    #It returns a movie test object that holds prediction/test data and basic statistical operations
    movie_test = MovieTest.new
    count = 0
    #Make sure there is a test set
    if @user_rated_test != nil
      @user_rated_test.each do |user_id, array_of_movies|
        array_of_movies.each do |movie_id, rating|
          if count == k
            return movie_test
          else
            prediction = predict(user_id, movie_id)
            movie_test.add_prediction(user_id, movie_id, rating, prediction)
            count += 1
          end
        end
      end
    end
    return movie_test
  end
end


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

m = MovieData.new('ml-100k', :u1)
t = m.run_test(100)
puts t.rms
