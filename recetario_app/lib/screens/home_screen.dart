import 'package:flutter/material.dart';
import '../data/recipes_data.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Todas';
  final Set<int> _favorites = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Quitar acentos y pasa a minúsculas para que "pure" encuentre "puré".
  String _normalize(String s) {
    const from = 'áéíóúüñ';
    const to = 'aeiouun';
    var result = s.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      result = result.replaceAll(from[i], to[i]);
    }
    return result;
  }

  List<Recipe> get _filteredRecipes {
    final q = _normalize(_query.trim());
    return recipes.where((r) {
      final matchesCategory = switch (_selectedCategory) {
        'Todas' => true,
        'Favoritos' => _favorites.contains(r.id),
        _ => r.category == _selectedCategory,
      };
      final matchesSearch = q.isEmpty ||
          _normalize(r.title).contains(q) ||
          _normalize(r.description).contains(q) ||
          r.ingredients.any((i) => _normalize(i).contains(q));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (!_favorites.add(id)) _favorites.remove(id);
    });
  }

  void _openDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          recipe: recipe,
          isFavorite: _favorites.contains(recipe.id),
          onFavoriteChanged: () => _toggleFavorite(recipe.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Recetario',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda funcional
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Buscar receta o ingrediente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Categorías (chips)
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = categories[i];
                final selected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  selectedColor: const Color(0xFFE4572E),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  checkmarkColor: Colors.white,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),

          // Lista dinámica
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('No se encontraron recetas',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final recipe = list[i];
                      return RecipeCard(
                        recipe: recipe,
                        isFavorite: _favorites.contains(recipe.id),
                        onTap: () => _openDetail(recipe),
                        onFavorite: () => _toggleFavorite(recipe.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
