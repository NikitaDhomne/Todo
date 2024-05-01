import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/model/task_model.dart';
import 'package:todo_app/provider/task_provider.dart';

import 'package:intl/intl.dart';
import 'package:todo_app/screens/Add_task.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<Color> cardColors = [
    Colors.indigo,
    Colors.orange,
  ];

  bool isDarkMode = false;
  DateTime selectedDate = DateTime.now();

  void onDaySelected(int day) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month, day);
      print(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMMM yyyy').format(now);
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int today = now.day;

    List<Widget> dayCircles = List.generate(daysInMonth - today + 1, (index) {
      // Generating circles for each day from today to the end of the month
      int day = today + index;
      Color circleColor;
      if (day == today) {
        circleColor = Colors.pink; // Today's circle color
      } else if (day == selectedDate.day) {
        circleColor = Colors.brown; // Selected date circle color
      } else {
        circleColor = Colors.indigoAccent; // Other days' circle color
      }
      return GestureDetector(
        onTap: () => onDaySelected(day),
        child: Column(
          children: [
            Text(
              '${DateFormat('MMM').format(DateTime(now.year, now.month))}',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 4),
            Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${DateFormat('E').format(DateTime(now.year, now.month, day))}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        centerTitle: true,
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddTaskScreen()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(
                          10), // Adjust the radius as needed
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    child: Text(
                      "New Task",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              ],
            ),

            Text(
              'Today',
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 10),
            // Horizontal list view of day circles
            Container(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: dayCircles,
              ),
            ),

            SizedBox(height: 20),
            Text(
              'Tasks',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            // Displaying tasks from the TaskProvider
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (context, taskProvider, _) {
                  List<Task> tasks = taskProvider.tasks.where((task) {
                    return task.date.day == selectedDate.day &&
                        task.date.month == selectedDate.month &&
                        task.date.year == selectedDate.year;
                  }).toList();

                  // Sort tasks based on their start time
                  tasks.sort((a, b) =>
                      a.startTime.hour * 60 +
                      a.startTime.minute -
                      (b.startTime.hour * 60 + b.startTime.minute));

                  if (tasks.isEmpty) {
                    return Center(
                      child: Text(
                        'No tasks',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      Task task = tasks[index];
                      Color cardColor = cardColors[index % cardColors.length];
                      return Dismissible(
                        key: Key(task.id), // Provide a unique key for each task
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          // Remove the task from the provider when dismissed
                          Provider.of<TaskProvider>(context, listen: false)
                              .deleteTask(task);
                        },
                        direction: DismissDirection.endToStart,
                        child: Card(
                          color: cardColor,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Task details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        task.description,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        '${task.startTime.format(context)}  to  ${task.endTime.format(context)}',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                // Status button
                                GestureDetector(
                                  onTap: () {
                                    Provider.of<TaskProvider>(context,
                                            listen: false)
                                        .toggleTaskCompletion(task);
                                  },
                                  child: Container(
                                      width: 100.0,
                                      height: 30.0,
                                      decoration: BoxDecoration(
                                        color: task.isCompleted
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      child: task.isCompleted
                                          ? Center(child: Text('Completed'))
                                          : Center(child: Text('Remaining'))),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
