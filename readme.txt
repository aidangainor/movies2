My main idea was to create two hash maps in the load_data method. One of these 
hashmaps would map a user_id to a list of movie_id and rating pairs. Therefore
this made it quite easy to extract what movies and what ratings a certain user
gave. I also had a hash map that mapped movie_ids to their popularity, and also
what user_ids rated that movie. Although it was not necessary to have a list of 
users who rated a given movie_id, I think this could be useful for part 2. I also
computed the popularities of each movie in the load_data method. My popularity 
metric was just the summation of all its ratings. My similarity method used the 
hash map to look up what movies both users rated, then compared their ratings. The
similarity number that was returned is the summation (5-abs(user1rating-user2rating))
for each movie they watched. 

Since I used hash maps and pre computed the popularity number in the load_data
method, my popularity_list algorithm scales fairly well and is only bound to the 
time it takes to sort the list. My most_similar method scales a litle worse, because
to compare both users we must match up the same movies they rated which uses nested
loops. However if I sorted the list of both rated movies I could have improved this
to O(nlogn) for similarity method, and then most similar would take O(n^2*logn) instead
of 0(n^3)

Like I said above, I also had a hash map that mapped movie_ids to a list of users who
rated that movie. This could be useful for predicting what a user U would rate a movie M,
as we could extract that list of users who rated that movie M and what their rating was,
and then average their ratings for the users who have a high similarity with user U.
