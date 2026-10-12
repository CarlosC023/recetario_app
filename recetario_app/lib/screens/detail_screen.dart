import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/recipe.dart';

class DetailScreen extends StatefulWidget {
  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;

  const DetailScreen({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool _isFavorite;
  late List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _checked = List.filled(widget.recipe.ingredients.length, false);
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteChanged();
    _showMessage(
        _isFavorite ? 'Agregada a favoritos ❤️' : 'Eliminada de favoritos');
  }

  Future<void> _share() async {
    final r = widget.recipe;
    final text = StringBuffer()
      ..writeln('🍽️ ${r.title}')
      ..writeln(
          '⏱️ ${r.minutes} min · ${r.difficulty} · ${r.servings} porciones')
      ..writeln()
      ..writeln('Ingredientes:');
    for (final i in r.ingredients) {
      text.writeln('• $i');
    }
    text.writeln();
    text.writeln('Preparación:');
    for (var i = 0; i < r.steps.length; i++) {
      text.writeln('${i + 1}. ${r.steps[i]}');
    }
    await Clipboard.setData(ClipboardData(text: text.toString()));
    if (!mounted) return;
    _showMessage('Receta copiada al portapapeles 📋');
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    const primary = Color(0xFFE4572E);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            title: Text(r.title),
            actions: [
              IconButton(
                icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'recipe-${r.id}',
                child: Image.network(
                  r.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.orange.shade100,
                    child: const Icon(Icons.restaurant,
                        size: 80, color: Colors.orange),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.title,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(r.category),
                    backgroundColor: primary.withAlpha(30),
                    side: BorderSide.none,
                  ),
                  const SizedBox(height: 12),

                  // Iconos informativos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoTile(
                          Icons.timer_outlined, '${r.minutes} min', 'Tiempo'),
                      _InfoTile(Icons.local_fire_department_outlined,
                          '${r.calories} kcal', 'Calorías'),
                      _InfoTile(
                          Icons.people_outline, '${r.servings}', 'Porciones'),
                      _InfoTile(Icons.star, '${r.rating}', r.difficulty,
                          color: Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text('Descripción',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(r.description,
                      style: const TextStyle(fontSize: 16, height: 1.4)),
                  const SizedBox(height: 24),

                  const Text('Ingredientes',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...List.generate(r.ingredients.length, (i) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: primary,
                      dense: true,
                      value: _checked[i],
                      onChanged: (v) =>
                          setState(() => _checked[i] = v ?? false),
                      title: Text(
                        r.ingredients[i],
                        style: TextStyle(
                          fontSize: 16,
                          decoration:
                              _checked[i] ? TextDecoration.lineThrough : null,
                          color: _checked[i] ? Colors.grey : Colors.black87,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  const Text('Preparación',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...List.generate(r.steps.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: primary,
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(r.steps[i],
                                style: const TextStyle(
                                    fontSize: 16, height: 1.4)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _toggleFavorite,
                  icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border),
                  label: Text(_isFavorite ? 'En favoritos' : 'Favorito'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: const BorderSide(color: primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _share,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const _InfoTile(this.icon, this.value, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color ?? const Color(0xFFE4572E)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}
