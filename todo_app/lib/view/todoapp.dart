import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resulte_practical/view/model/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  var tasks = <Task>[];
  var filterTasks = <Task>[];
  var taskController = TextEditingController();
  var isEdit = false;
  var editTaskId = 0;
  String selectedPriority = 'Low';
  String filterPriority = 'All';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTasks();
  }

  bool isStringNullOrEmptyOrBlank(String value) {
    return value.isEmpty || value.trim().isEmpty;
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      setState(() {
        tasks = Task.decode(tasksString);
        filterTasks = tasks;
      });
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = Task.encode(tasks);
    await prefs.setString('tasks', tasksString);
  }

  void addTask() {
    String taskTitle = taskController.text.trim();

    if (!isStringNullOrEmptyOrBlank(taskTitle)) {
      setState(() {
        if (isEdit) {
          tasks.forEach((element) {
            if (element.id == editTaskId) {
              element.title = taskTitle;
              element.priority = selectedPriority;

              isEdit = false;
            }
          });
        } else {
          if (tasks.isNotEmpty && tasks.length > 0) {
            tasks.add(
              Task(
                id: tasks.length + 1,
                title: taskTitle,
                isCompleted: false,
                isEdit: false,
                priority: selectedPriority,
              ),
            );
          } else {
            tasks.add(
              Task(
                id: 1,
                title: taskTitle,
                isCompleted: false,
                isEdit: false,
                priority: selectedPriority,
              ),
            );
          }
        }
        taskController.clear();
        saveTasks();
        filterTasks = tasks;
      });
    } else {
      showSnackBar("Please enter valid task");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color.fromARGB(255, 219, 129, 122),
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void deleteTask(int index) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text(
              'Do you want to delete this task?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    //  tasks.removeAt(index);
                    filterTasks.removeAt(index);
                    saveTasks();
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(255, 51, 212, 15),
                  ),
                  child: const Center(
                    child: Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(255, 222, 10, 10),
                  ),
                  child: const Center(
                    child: Text(
                      'No',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void editTask(Task task) {
    setState(() {
      taskController.text = task.title ?? "";
      isEdit = true;
      selectedPriority = task.priority ?? 'Low';
      editTaskId = task.id ?? 0; // Set the task updated id
    });
  }

  void changeStatus(int index) {
    setState(() {
      tasks[index].isCompleted = !(tasks[index].isCompleted ?? false);
      saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'TO DO LIST',
          style: TextStyle(
            color: Color.fromARGB(255, 26, 5, 55),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 2,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 123, 203, 182),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Add Task",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: TextFormField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter task",
                      hintStyle:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      alignment: Alignment.topRight,
                      value: selectedPriority,
                      items:
                          <String>['Low', 'Medium', 'High'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPriority = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () {
                    addTask();
                  },
                  color: const Color.fromARGB(255, 123, 203, 182),
                  child: Text(
                    (isEdit) ? "Update Task" : "Add Task",
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Task List",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Text("Filter by Priority:"),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        alignment: Alignment.topRight,
                        value: filterPriority,
                        items: <String>['All', 'Low', 'Medium', 'High']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            filterPriority = newValue!;
                            filterTasks = tasks.where((task) {
                              return ((filterPriority == 'All') ||
                                  (task.priority == filterPriority));
                            }).toList();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: filterTasks.length > 0
                    ? ListView.separated(
                        itemCount: filterTasks.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: (filterTasks[index]
                                              .priority
                                              ?.toLowerCase() ==
                                          "high")
                                      ? const Color.fromARGB(255, 153, 38, 29)
                                      : (filterTasks[index]
                                                  .priority
                                                  ?.toLowerCase() ==
                                              "medium")
                                          ? const Color.fromARGB(
                                              255, 234, 153, 31)
                                          : (filterTasks[index]
                                                      .priority
                                                      ?.toLowerCase() ==
                                                  "low")
                                              ? const Color.fromARGB(
                                                  255, 74, 236, 80)
                                              : const Color.fromARGB(
                                                  255, 231, 231, 231),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 0.2,
                                    color: Color.fromARGB(255, 95, 94, 94),
                                    offset: Offset(0.2, 0.2),
                                    spreadRadius: 0.2,
                                    blurStyle: BlurStyle.outer,
                                  )
                                ]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: filterTasks[index].isCompleted,
                                  onChanged: (bool? value) {
                                    changeStatus(index);
                                  },
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  (filterTasks[index].title ?? ""),
                                  style: TextStyle(
                                    decoration:
                                        (filterTasks[index].isCompleted ??
                                                false)
                                            ? TextDecoration.lineThrough
                                            : null,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color.fromARGB(255, 236, 120, 107),
                                  ),
                                  onPressed: () => deleteTask(index),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color.fromARGB(255, 233, 159, 32),
                                  ),
                                  onPressed: () => editTask(filterTasks[index]),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                      )
                    : const Center(
                        child: Text("There is no task found for your priority"),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
