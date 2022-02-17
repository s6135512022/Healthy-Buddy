class APIPath {
  static String job(String uid, String jobId) => 'users/$uid/jobs/$jobId';
  static String jobs(String uid) => 'users/$uid/jobs';
  static String entry(String uid, String entryId) =>
      'users/$uid/entries/$entryId';
  static String entries(String uid) => 'users/$uid/entries';

  //*** PRJ-1 */
  static String jobsList() => 'workouts';
  static String jobGet(String jobID) => 'workouts/$jobID';
  static String profile(String uid) => 'users/$uid';

  //*** PRJ-2.1 */
  static String foodsList() => 'foods';

  //*** PRJ-2.2 */
  static String recipe(String uid, String recipeId) =>
      'users/$uid/recipes/$recipeId';
  static String recipes(String uid) => 'users/$uid/recipes';
}
