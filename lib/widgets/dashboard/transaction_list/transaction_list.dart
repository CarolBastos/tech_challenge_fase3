import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'convertMonthToPortuguese.dart';

class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  static const _pageSize = 10;
  final PagingController<int, DocumentSnapshot> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchNextPage(pageKey);
    });
  }

  Future<void> _fetchNextPage(int pageKey) async {
    try {
      final Query query = FirebaseFirestore.instance
          .collection('transacoes')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('data', descending: true)
          .limit(_pageSize);

      QuerySnapshot snapshot;
      if (pageKey == 0) {
        snapshot = await query.get();
      } else {
        final lastDoc = _pagingController.itemList?.last;
        snapshot = await query.startAfterDocument(lastDoc!).get();
      }

      final isLastPage = snapshot.docs.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(snapshot.docs);
      } else {
        _pagingController.appendPage(snapshot.docs, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    var format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extrato',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height:
                  MediaQuery.of(context).size.height *
                  0.5, // Definindo altura fixa
              child: PagedListView<int, DocumentSnapshot>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<DocumentSnapshot>(
                  itemBuilder: (context, transacao, index) {
                    var dataTransacao = transacao['data'];
                    if (dataTransacao == null || dataTransacao is! Timestamp) {
                      return ListTile(title: Text('Erro: Data inválida'));
                    }

                    DateTime data = dataTransacao.toDate();
                    String dataFormatada = DateFormat(
                      'dd/MM/yyyy',
                    ).format(data);
                    var month = DateFormat('MMMM').format(data);
                    var monthInPortuguese = convertMonthToPortuguese(month);

                    double valor =
                        transacao['valor'] is double
                            ? transacao['valor']
                            : double.tryParse(transacao['valor'].toString()) ??
                                0.0;

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$monthInPortuguese',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '${transacao['tipo']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '${format.format(valor)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$dataFormatada',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.greyPlaceholder,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  firstPageProgressIndicatorBuilder:
                      (context) => Center(child: CircularProgressIndicator()),
                  newPageProgressIndicatorBuilder:
                      (context) => Center(child: CircularProgressIndicator()),
                  firstPageErrorIndicatorBuilder:
                      (context) =>
                          Center(child: Text('Erro ao carregar transações')),
                  noMoreItemsIndicatorBuilder:
                      (context) =>
                          Center(child: Text('Não há mais transações')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
