class Recipe {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final int minutes;
  final String difficulty;
  final int calories;
  final double rating;
  final int servings;
  final List<String> ingredients;
  final List<String> steps;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.minutes,
    required this.difficulty,
    required this.calories,
    required this.rating,
    required this.servings,
    required this.ingredients,
    required this.steps,
  });
}
