import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import 'tabs/accueil_tab.dart';
import 'tabs/commandes_tab.dart';
import 'tabs/clients_tab.dart';
import 'tabs/mon_atelier_tab.dart';

class TailleurHomeScreen extends StatefulWidget {
  final Tailleur tailleur;
  const TailleurHomeScreen({Key? key, required this.tailleur})
    : super(key: key);

  @override
  _TailleurHomeScreenState createState() => _TailleurHomeScreenState();
}

class _TailleurHomeScreenState extends State<TailleurHomeScreen> {
  int _index = 0;

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pages = [
      AccueilTab(tailleur: widget.tailleur, onChanged: _refresh),
      CommandesTab(tailleur: widget.tailleur, onChanged: _refresh),
      ClientsTab(tailleur: widget.tailleur, onChanged: _refresh),
      MonAtelierTab(tailleur: widget.tailleur),
    ];

    final items = [
      {'icon': Icons.home_filled, 'label': 'Accueil'},
      {'icon': Icons.shopping_bag_outlined, 'label': 'Commandes'},
      {'icon': Icons.person_outline, 'label': 'Clients'},
      {'icon': Icons.content_cut, 'label': 'Mon Atelier'},
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kCard,
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _index == i;
              return GestureDetector(
                onTap: () => setState(() => _index = i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selected
                              ? kOrange.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          items[i]['icon'] as IconData,
                          color: selected ? kOrange : Colors.grey[500],
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected ? kOrange : Colors.grey[500],
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
