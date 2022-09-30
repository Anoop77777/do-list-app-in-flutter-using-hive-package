import 'package:dolist/main.dart';
import 'package:dolist/todo/data_model.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String dataBoxName = "data";

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum DataFilter { ALL, COMPLETED, PROGRESS }

class _MyHomePageState extends State<MyHomePage> {
  Box<DataModel> dataBox;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DataFilter filter = DataFilter.ALL;

  @override
  void initState() {
    super.initState();
    dataBox = Hive.box<DataModel>(dataBoxName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //backgroundColor: Colors.black,
        title: Text("Do List"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value.compareTo("All") == 0) {
                setState(() {
                  filter = DataFilter.ALL;
                });
              } else if (value.compareTo("Compeleted") == 0) {
                setState(() {
                  filter = DataFilter.COMPLETED;
                });
              } else {
                setState(() {
                  filter = DataFilter.PROGRESS;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return ["All", "Compeleted", "Progress"].map((option) {
                return PopupMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: dataBox.listenable(),
              builder: (context, Box<DataModel> items, _) {
                List<int> keys;

                if (filter == DataFilter.ALL) {
                  keys = items.keys.cast<int>().toList();
                } else if (filter == DataFilter.COMPLETED) {
                  keys = items.keys
                      .cast<int>()
                      .where((key) => items.get(key).complete)
                      .toList();
                } else {
                  keys = items.keys
                      .cast<int>()
                      .where((key) => !items.get(key).complete)
                      .toList();
                }

                return keys.length == 0
                    ? EmptyList()
                    : ListView.separated(
                        separatorBuilder: (_, index) => Divider(),
                        itemCount: keys.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.all(15),
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (_, index) {
                          final int key = keys[index];
                          final DataModel data = items.get(key);
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.blueGrey[200],
                            child: ListTile(
                              title: Text(
                                data.title,
                                style: TextStyle(
                                    fontSize: 22, color: Colors.black),
                              ),
                              subtitle: Text(data.description,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 5,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black38)),
                              // leading: Text(
                              //   "$key",
                              //   style: TextStyle(
                              //       fontSize: 18, color: Colors.black),
                              // ),
                              trailing: Icon(
                                Icons.check,
                                color: data.complete
                                    ? Colors.deepPurpleAccent
                                    : Colors.red,
                              ),
                              onTap: () {
                                data.complete
                                    ? showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              backgroundColor: Colors.white,
                                              content: Container(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary:
                                                            Color(0xff0D3257),
                                                        side: BorderSide(
                                                            color: Colors.black,
                                                            width: 1),
                                                        textStyle:
                                                            const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal),
                                                      ),
                                                      child: Text(
                                                        "Mark as in progress",
                                                        // style: TextStyle(
                                                        //     color:
                                                        //         Colors.black87),
                                                      ),
                                                      onPressed: () {
                                                        DataModel mData =
                                                            DataModel(
                                                                title:
                                                                    data.title,
                                                                description: data
                                                                    .description,
                                                                complete:
                                                                    false);
                                                        dataBox.put(key, mData);
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ));
                                        })
                                    : showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              backgroundColor: Colors.white,
                                              content: Container(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary:
                                                            Color(0xff0D3257),
                                                        side: BorderSide(
                                                            color: Colors.black,
                                                            width: 1),
                                                        textStyle:
                                                            const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal),
                                                      ),
                                                      child: Text(
                                                        "Mark as complete",
                                                        // style: TextStyle(
                                                        //     color:
                                                        //         Colors.black87),
                                                      ),
                                                      onPressed: () {
                                                        DataModel mData =
                                                            DataModel(
                                                                title:
                                                                    data.title,
                                                                description: data
                                                                    .description,
                                                                complete: true);
                                                        dataBox.put(key, mData);
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ));
                                        });
                              },
                            ),
                          );
                        },
                      );
              },
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            key: UniqueKey(),
            backgroundColor: Color(0xff0D3257),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Are you sure"),
                    content: Text("Do you want delete all tasks? "),
                    actions: <Widget>[
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                      TextButton(
                        child: Text("Confirm"),
                        onPressed: () async {
                          await dataBox.clear();
                          Navigator.pop(context, true);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(Icons.delete),
          ),
          SizedBox(width: 5),
          FloatingActionButton(
            key: UniqueKey(),
            backgroundColor: Color(0xff0D3257),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        backgroundColor: Colors.blueGrey[50],
                        content: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("Task",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              SizedBox(height: 15),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: "Title",
                                  border: OutlineInputBorder(),
                                ),
                                controller: titleController,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              TextField(
                                maxLines: 5,
                                minLines: 3,
                                decoration: InputDecoration(
                                  labelText: "Description",
                                  border: OutlineInputBorder(),
                                ),
                                controller: descriptionController,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xff0D3257),
                                    side: BorderSide(
                                        color: Colors.black, width: 1),
                                    textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  child: Text("Add Task"),
                                  onPressed: () {
                                    final String title = titleController.text;
                                    final String description =
                                        descriptionController.text;
                                    titleController.clear();
                                    descriptionController.clear();
                                    DataModel data = DataModel(
                                        title: title,
                                        description: description,
                                        complete: false);
                                    dataBox.add(data);
                                    Navigator.pop(context);
                                  },
                                ),
                              )
                            ],
                          ),
                        ));
                  });
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
