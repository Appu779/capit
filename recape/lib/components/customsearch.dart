import 'package:flutter/material.dart';
import 'package:recape/components/classdetails.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<ClassroomTileData> classrooms;
  final Function(ClassroomTileData) onSelect;

  CustomSearchDelegate(this.classrooms, this.onSelect);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<ClassroomTileData> searchResults = classrooms
        .where((classroom) =>
            classroom.className.toLowerCase().contains(query.toLowerCase()) ||
            classroom.academicYear.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index].className),
          subtitle: Text('Academic Year: ${searchResults[index].academicYear}'),
          onTap: () {
            onSelect(searchResults[index]);
            close(context, null);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<ClassroomTileData> suggestionList = classrooms
        .where((classroom) =>
            classroom.className.toLowerCase().contains(query.toLowerCase()) ||
            classroom.academicYear.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].className),
          subtitle:
              Text('Academic Year: ${suggestionList[index].academicYear}'),
          onTap: () {
            onSelect(suggestionList[index]);
            close(context, null);
          },
        );
      },
    );
  }
}
