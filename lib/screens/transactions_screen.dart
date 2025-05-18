// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/app_state.dart';
import 'package:tech_challenge_fase3/screens/components/dashboard/transaction_list/transaction_list_filtered.dart';
import 'package:tech_challenge_fase3/models/user_state.dart';
import 'components/dashboard/menu/custom_app_bar.dart';
import 'components/dashboard/menu/custom_drawer.dart';

import 'package:flutter_redux/flutter_redux.dart';

class FilteredTransactionScreen extends StatefulWidget {
  @override
  _FilteredTransactionScreenState createState() =>
      _FilteredTransactionScreenState();
}

class _FilteredTransactionScreenState extends State<FilteredTransactionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  double? _selectedValue;
  String? _selectedType;
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final List<String> tiposTransacao = ['Depósito', 'Saque', 'Transferência'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _applyFilters() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _selectedValue = double.tryParse(_valueController.text);
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedDate = null;
      _selectedValue = null;
      _selectedType = null;
      _valueController.clear();
      _typeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, UserState>(
      converter: (store) => store.state.userState,
      builder: (context, userState) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.teaGreen,
          appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
          drawer: const CustomDrawer(),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      "Olá, ${userState.displayName}! :)",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Saldo: R\$ ${userState.balance.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                "Filtrar Transações",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Campo de Data
                              InkWell(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: "Data",
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedDate == null
                                            ? "Selecione uma data"
                                            : DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(_selectedDate!),
                                      ),
                                      const Icon(Icons.calendar_today),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Campo de Valor
                              TextFormField(
                                controller: _valueController,
                                decoration: InputDecoration(
                                  labelText: "Valor",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  if (value!.isNotEmpty &&
                                      double.tryParse(value) == null) {
                                    return "Insira um valor válido";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Campo de Tipo de Transferência
                              DropdownButtonFormField<String>(
                                value: _selectedType,
                                decoration: InputDecoration(
                                  labelText: "Tipo de Transferência",
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    tiposTransacao.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedType = newValue;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              // Botões de Aplicar e Limpar Filtros
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: _applyFilters,
                                    child: const Text("Aplicar Filtros"),
                                  ),
                                  TextButton(
                                    onPressed: _clearFilters,
                                    child: const Text("Limpar Filtros"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
                // Widget TransactionList com filtros aplicados
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return TransactionListFiltered(
                      data: _selectedDate,
                      valor: _selectedValue,
                      tipoTransferencia: _selectedType,
                    );
                  }, childCount: 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
