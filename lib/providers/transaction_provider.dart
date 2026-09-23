import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/database.dart';
import '../data/repositories/transaction_repository.dart';

// Provider yang menerima parameter int (accountId)
final accountTransactionsProvider =
    StreamProvider.family<List<Transaction>, int>((ref, accountId) {
      final repository = ref.watch(transactionRepositoryProvider);
      return repository.watchTransactionsByAccount(accountId);
    });
