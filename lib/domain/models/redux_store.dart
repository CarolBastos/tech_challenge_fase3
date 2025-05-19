import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:redux/redux.dart';
import 'user_state.dart';
import 'user_reducer.dart';

Future<Store<UserState>> configureStore() async {
  final persistor = Persistor<UserState>(
    storage: FlutterStorage(),
    serializer: JsonSerializer<UserState>((dynamic json) {
      if (json is Map<String, dynamic>) {
        return UserState.fromJson(json);
      }
      return UserState(); // Retorna estado inicial se não for o tipo esperado
    }),
  );

  UserState? initialState;
  try {
    initialState = await persistor.load();
  } catch (e) {
    print("Error loading persisted state: $e");
  }

  return Store<UserState>(
    userReducer,
    initialState: initialState ?? UserState(),
    middleware: [persistor.createMiddleware()],
  );
}