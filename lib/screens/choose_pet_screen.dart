import 'package:flutter/material.dart';
import 'package:ocean_pet/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChoosePetScreen extends StatefulWidget {
  @override
  State<ChoosePetScreen> createState() => _ChoosePetScreenState();
}

class _ChoosePetScreenState extends State<ChoosePetScreen> {
  Future<void> _saveSelectedPets() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedPetNames =
        selectedIndexes.map((i) => pets[i]['title'] as String).toList();
    await prefs.setStringList('selected_pets', selectedPetNames);
  }

  final Set<int> selectedIndexes = {};
  final List<Map<String, dynamic>> pets = [
    {
      'title': 'Mèo',
      'image': 'lib/res/drawables/setting/001-cat.png',
      'color': Color(0xFFEDE9FE), // tím nhạt
      'textColor': Color(0xFF8B5CF6),
    },
    {
      'title': 'Cá',
      'image': 'lib/res/drawables/setting/002-fish.png',
      'color': Color(0xFFE0F2FE), // xanh nước nhạt
      'textColor': Color(0xFF60A5FA),
    },
    {
      'title': 'Rắn',
      'image': 'lib/res/drawables/setting/003-snake.png',
      'color': Color(0xFFFEE2E2), // đỏ nhạt
      'textColor': Color(0xFFFB7185),
    },
    {
      'title': 'Rùa',
      'image': 'lib/res/drawables/setting/004-turtle.png',
      'color': Color(0xFFD1FAE5), // xanh lá nhạt
      'textColor': Color(0xFF34D399),
    },
    {
      'title': 'Heo',
      'image': 'lib/res/drawables/setting/005-pig.png',
      'color': Color(0xFFFFF7ED), // cam nhạt
      'textColor': Color(0xFFF59E42),
    },
    {
      'title': 'Thỏ',
      'image': 'lib/res/drawables/setting/006-rabbit.png',
      'color': Color(0xFFD1FAE5), // xanh lá nhạt
      'textColor': Color(0xFF10B981),
    },
    {
      'title': 'Chó',
      'image': 'lib/res/drawables/setting/007-dog.png',
      'color': Color(0xFFEDE9FE), // tím nhạt
      'textColor': Color(0xFF6366F1),
    },
    {
      'title': 'Vẹt',
      'image': 'lib/res/drawables/setting/008-parrot.png',
      'color': Color(0xFFFEE2E2), // đỏ nhạt
      'textColor': Color(0xFFEC4899),
    },
    {
      'title': 'Hamster',
      'image': 'lib/res/drawables/setting/009-squirrel.png',
      'color': Color(0xFFFFF7ED), // cam nhạt
      'textColor': Color(0xFFB45309),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chọn thú cưng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn muốn chăm sóc thú cưng nào?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: pets.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  final isSelected = selectedIndexes.contains(index);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedIndexes.remove(index);
                        } else {
                          selectedIndexes.add(index);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: pet['color'],
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(color: pet['textColor'], width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: pet['textColor'].withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: Offset(0, 2))
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            pet['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            pet['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: pet['textColor'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedIndexes.isNotEmpty
                    ? () async {
                        await _saveSelectedPets();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ),
                        );
                      }
                    : null,
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
                  backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey.shade200;
                    }
                    return Color(0xFF8B5CF6);
                  }),
                  elevation: MaterialStateProperty.all(0),
                ),
                child: Text(
                  'Xác nhận',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        selectedIndexes.isNotEmpty ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
