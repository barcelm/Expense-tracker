import 'dart:io';

import 'package:expenses/models/expense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _costController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.Jedzenie;

  void _presentDayPicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedData = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: firstDate,
        lastDate: now);
    setState(() {
      _selectedDate = pickedData;
    });
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
                title: const Text("Niepoprawne dane"),
                content: const Text(
                    "Upewnij się, że tytuł, kwota, data i kategoria są poprawnie wprowadzone."),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text("Ok"))
                ],
              ));
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Niepoprawne dane"),
          content: const Text(
              "Upewnij się, że tytuł, kwota, data i kategoria są poprawnie wprowadzone."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text("Ok"))
          ],
        ),
      );
    }
  }

  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_costController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;
    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      _showDialog();
      return;
    }
    widget.onAddExpense(Expense(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    super.dispose();
  }

  ///var _enteredTitle = "";
  ///void _saveTitleInput(String inputValue){
  ///  _enteredTitle = inputValue;

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(builder: (ctx, constraints) {
      final width = constraints.maxWidth;
      final categoryButton = DropdownButton(
          value: _selectedCategory,
          items: Category.values
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(
                    category.name.toUpperCase(),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _selectedCategory = value;
            });
          });
      final displayButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Anuluj"),
      );
      final saveButton = ElevatedButton(
        onPressed: _submitExpenseData,
        child: const Text("Zapisz wydatek"),
      );
      final titleField = TextField(
        controller: _titleController,

        ///onChanged: _saveTitleInput,
        maxLength: 50,
        decoration: const InputDecoration(label: Text("Tytuł")),
      );
      final pickDate = Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_selectedDate == null
                ? "Wybierz datę"
                : formatter.format(_selectedDate!)),
            IconButton(
                onPressed: _presentDayPicker,
                icon: const Icon(Icons.calendar_month_outlined))
          ],
        ),
      );
      final amountField = Expanded(
        child: TextField(
          controller: _costController,
          decoration: const InputDecoration(
            prefixText: 'PLN ',
            label: Text("Kwota"),
          ),
          keyboardType: TextInputType.number,
        ),
      );

      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
          child: Column(
            children: [
              if (width >= 600)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: titleField,
                    ),
                    const SizedBox(
                      width: 24,
                    ),
                    amountField,
                  ],
                )
              else
                titleField,
              if (width >= 600)
                Row(
                  children: [
                    categoryButton,
                    pickDate,
                  ],
                )
              else
                Row(
                  children: [
                    amountField,
                    const SizedBox(
                      width: 20,
                    ),
                    pickDate,
                  ],
                ),
              const SizedBox(
                height: 16,
              ),
              if (width >= 600)
                Row(
                  children: [
                    const Spacer(),
                    displayButton,
                    saveButton,
                  ],
                )
              else
                Row(
                  children: [
                    categoryButton,
                  ],
                )
            ],
          ),
        ),
      );
    });
  }
}
