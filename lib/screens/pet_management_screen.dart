// lib/screens/pet_management_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocean_pet/services/FirebaseService.dart';
import 'package:ocean_pet/screens/edit_pet_profile_screen.dart';

class PetManagementScreen extends StatefulWidget {
  const PetManagementScreen({super.key});

  @override
  State<PetManagementScreen> createState() => _PetManagementScreenState();
}

class _PetManagementScreenState extends State<PetManagementScreen> {
  List<Map<String, dynamic>> pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loadedPets = await FirebaseService.getPets();
      setState(() {
        pets = loadedPets;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading pets: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kh�ng th? t?i danh s�ch th� c�ng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E97FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Qu?n l? th� c�ng',
          style: GoogleFonts.afacad(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadPets,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E97FD)),
              ),
            )
          : pets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ch�a c� th� c�ng n�o',
                        style: GoogleFonts.afacad(
                          fontSize: 18,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return _buildPetCard(pet);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditPetProfileScreen(),
            ),
          );
          if (result == true) {
            _loadPets();
          }
        },
        backgroundColor: const Color(0xFF8E97FD),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Th�m th� c�ng',
          style: GoogleFonts.afacad(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Format age from months to years/months display
  String _formatAgeDisplay(int? ageMonths) {
    if (ageMonths == null) return 'Ch�a r?';
    
    if (ageMonths < 12) {
      return '$ageMonths th�ng';
    } else {
      int years = ageMonths ~/ 12;
      int months = ageMonths % 12;
      if (months == 0) {
        return '$years n�m';
      } else {
        return '$years n�m $months th�ng';
      }
    }
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    final String name = pet['name'] ?? 'Kh�ng c� t�n';
    final String type = pet['type'] ?? 'Kh�ng r? lo?i';
    final String? breed = pet['breed'];
    final int? age = pet['age'];
    final double? weight = pet['weight'];
    final double? height = pet['height'];
    final String gender = pet['gender'] ?? 'unknown';
    final String? avatarUrl = pet['avatar_url'];

    String genderDisplay = gender == 'male' ? '�?c' : gender == 'female' ? 'C�i' : 'Kh�c';
    IconData genderIcon = gender == 'male' ? Icons.male : gender == 'female' ? Icons.female : Icons.help_outline;
    String ageDisplay = _formatAgeDisplay(age);
    String weightDisplay = weight != null ? '${weight}kg' : 'Ch�a r?';
    String heightDisplay = height != null ? '${height}cm' : 'Ch�a r?';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E97FD).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPetProfileScreen(existingPet: pet),
            ),
          );
          if (result == true) {
            _loadPets();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E97FD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  image: avatarUrl != null && avatarUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? const Icon(Icons.pets, size: 40, color: Color(0xFF8E97FD))
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.afacad(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF22223B))),
                    const SizedBox(height: 4),
                    Text(
                      breed != null && breed.isNotEmpty ? '$type - $breed  $ageDisplay' : '$type  $ageDisplay',
                      style: GoogleFonts.afacad(fontSize: 14, color: const Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(genderIcon, size: 16, color: const Color(0xFF8E97FD)),
                        const SizedBox(width: 4),
                        Text('$genderDisplay', style: GoogleFonts.afacad(fontSize: 13, color: const Color(0xFF6B7280))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$weightDisplay  |  $heightDisplay',
                      style: GoogleFonts.afacad(fontSize: 13, color: const Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF8E97FD)),
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditPetProfileScreen(existingPet: pet)));
                    if (result == true) _loadPets();
                  } else if (value == 'delete') {
                    _confirmDeletePet(pet);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit, color: Color(0xFF8E97FD)), const SizedBox(width: 8), Text('Ch?nh s?a', style: GoogleFonts.afacad())])),
                  PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, color: Color(0xFFEF5350)), const SizedBox(width: 8), Text('X�a', style: GoogleFonts.afacad())])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeletePet(Map<String, dynamic> pet) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('X�a th� c�ng', style: GoogleFonts.afacad(fontWeight: FontWeight.bold, color: const Color(0xFFEF5350))),
          content: Text('B?n c� ch?c ch?n mu?n x�a ${pet['name']}?', style: GoogleFonts.afacad()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('H?y', style: GoogleFonts.afacad(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseService.deletePet(pet['id']);
                  Navigator.pop(context);
                  _loadPets();
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('�? x�a ${pet['name']}'), backgroundColor: const Color(0xFF66BB6A)));
                } catch (e) {
                  Navigator.pop(context);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('L?i khi x�a: $e'), backgroundColor: const Color(0xFFEF5350)));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('X�a', style: GoogleFonts.afacad(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
