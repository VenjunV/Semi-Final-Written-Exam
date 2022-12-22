import 'package:assignment_sql_vallente/database.dart';
import 'package:flutter/material.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // All data
  List<Map<String, dynamic>> myData = [];
  final formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshData() async {
    final data = await Database.getItems();
    setState(() {
      myData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();


  void showMyForm(int? id) async {

    if (id != null) {
      final existingData = myData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descriptionController.text = existingData['description'];
    } else {
      _titleController.text = "";
      _descriptionController.text = "";
    }

    //Sheet and form
      showModalBottomSheet(
      backgroundColor: Colors.yellow,
        context: context,
        elevation: 5,
        isDismissible: false,
        isScrollControlled: true,
        builder: (_) => Container(
            padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              // prevent the soft keyboard from covering the text fields
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget> [
                  TextFormField(
                    controller: _titleController,
                    validator: formValidator,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Title: '),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 6,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    validator: formValidator,
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'Description:'),
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: 6,
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  //Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Exit button
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.yellow,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Exit")),
                      //Create and Update button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.yellow,
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (id == null) {
                              await addItem();
                            }

                            if (id != null) {
                              await updateItem(id);
                            }

                            // Clear
                            setState(() {
                              _titleController.text = '';
                              _descriptionController.text = '';
                            });

                            // Close
                            Navigator.pop(context);
                          }
                          // Save
                        },
                        child: Text(id == null ? 'Create' : 'Update'),
                      ),
                    ],
                  )
                ],
              ),
            )));
  }

  String? formValidator(String? value) {
    if (value!.isEmpty) return 'Field is Required';
    return null;
  }

// Insert a new data
  Future<void> addItem() async {
    await Database.createItem(
        _titleController.text, _descriptionController.text);
    _refreshData();
  }

  // Update
  Future<void> updateItem(int id) async {
    await Database.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshData();
  }

  // Delete
  void deleteItem(int id) async {
    await Database.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully deleted!'), backgroundColor: Colors.black));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.notes),
        title: const Text('To Do'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : myData.isEmpty
          ? const Center(child: Text("Empty"))
          : ListView.builder(
              itemCount: myData.length,
              itemBuilder: (context, index) => Card(
                color: index % 2 == 0 ? Colors.yellow : Colors.yellow[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  leading: const Icon(Icons.notes),
                  title: Text(myData[index]['title']),
                  subtitle: Text(myData[index]['description']),
                  trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                     IconButton(
                      color: Colors.black,
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          showMyForm(myData[index]['id']),
                    ),
                    IconButton(
                      color: Colors.black,
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          deleteItem(myData[index]['id']),
                    ),
                  ],
                ),
              )),
          ),
      ),
      //For floating Button

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellow,
        child: const Icon(Icons.add),
        onPressed: () => showMyForm(null),
      ),
    );
  }
}