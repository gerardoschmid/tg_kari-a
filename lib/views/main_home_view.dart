import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karina_app/providers/auth_provider.dart'; // Ajusta según tu nombre de proyecto
import 'package:karina_app/providers/local_provider.dart';
import 'package:karina_app/views/decklist.dart'; // Para navegar a tus lecciones

class MainHomeView extends StatelessWidget {
  const MainHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos los providers para nombre, nivel e idioma
    final auth = Provider.of<AuthProvider>(context);
    final locale = Provider.of<LocalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: Text(
          locale.locale.languageCode == 'es' ? 'Mi Progreso' : 'My Progress',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Menú para cambiar idioma
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (val) => locale.setLocale(Locale(val)),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'es', child: Text("Español")),
              const PopupMenuItem(value: 'en', child: Text("English")),
            ],
          ),
          // Botón de Cerrar Sesión
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => auth.logout(),
          )
        ],
      ),
      backgroundColor: Colors.green[50],
      body: Column(
        children: [
          // Cabecera: Info del Usuario
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ayombo, ${auth.userName}!", // Ayombo es "Hola" en Kariña
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.yellow[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${locale.locale.languageCode == 'es' ? 'Nivel' : 'Level'}: ${auth.level}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Título del menú
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                locale.locale.languageCode == 'es' ? 'Tu Camino de Aprendizaje' : 'Your Learning Path',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
            ),
          ),

          // Menú interactivo de niveles
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildLevelTile(
                  context, 
                  "Nivel 1: Vocabulario Básico", 
                  true, 
                  locale.locale.languageCode
                ),
                _buildLevelTile(
                  context, 
                  "Nivel 2: Colores y Formas", 
                  true, 
                  locale.locale.languageCode
                ),
                _buildLevelTile(
                  context, 
                  "Nivel 3: Animales de la Selva", 
                  false, 
                  locale.locale.languageCode
                ),
                _buildLevelTile(
                  context, 
                  "Nivel 4: Frases Comunes", 
                  false, 
                  locale.locale.languageCode
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLevelTile(BuildContext context, String title, bool unlocked, String lang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: unlocked ? 4 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: unlocked ? Colors.white : Colors.grey[300],
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(
          unlocked ? Icons.play_circle_fill : Icons.lock,
          color: unlocked ? Colors.green[700] : Colors.grey[600],
          size: 40,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: unlocked ? Colors.brown[800] : Colors.grey[600],
          ),
        ),
        subtitle: Text(unlocked 
          ? (lang == 'es' ? 'Toca para empezar' : 'Tap to start') 
          : (lang == 'es' ? 'Bloqueado' : 'Locked')
        ),
        trailing: Icon(Icons.chevron_right, color: unlocked ? Colors.green : Colors.grey),
        onTap: unlocked ? () {
          // NAVEGACIÓN A TU CLASE DECKLIST EXISTENTE
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DeckList()),
          );
        } : null,
      ),
    );
  }
}