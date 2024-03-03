import 'dart:math'; // Import the 'dart:math' library for random number generation
import 'package:flutter/material.dart';
import 'package:recape/components/classdetails.dart';

class ClassroomTile extends StatelessWidget {
  final ClassroomTileData data;
  final VoidCallback onDelete;
  final VoidCallback onSelect;

  ClassroomTile({
    Key? key,
    required this.data,
    required this.onDelete,
    required this.onSelect,
  }) : super(key: key);

  final List<String> tileImages = [
    'assets/images/s1.jpg',
    'assets/images/s4.jpg',
    'assets/images/s5.jpg',
    'assets/images/s6.jpg',
    'assets/images/s7.jpg',
    // Add more images as needed
  ];

  @override
  Widget build(BuildContext context) {
    // Generate a random index for the tileImages list
    final Random random = Random();
    final int randomIndex = random.nextInt(tileImages.length);

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        decoration: BoxDecoration(
          color: data.tileColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(tileImages[randomIndex]),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete(); // Call delete method
                  }
                },
                itemBuilder: (BuildContext context) {
                  return ['delete'].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: const Text('Delete'),
                    );
                  }).toList();
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.className,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Academic Year: ${data.academicYear}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
