class Business {
  final String id;
  final String name;
  final String category;
  final String location;
  final bool isActive;
  final List<String> enabledModules;

  const Business({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.isActive,
    required this.enabledModules,
  });
}