class Product {
  final String id;
  final String name;
  final String imagePath;
  final double price;
  final String category;
  final String description;
  final double rating;

  const Product({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.description,
    this.rating = 4.5,
  });
}
